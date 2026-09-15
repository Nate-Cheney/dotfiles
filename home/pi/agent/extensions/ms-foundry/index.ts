/**
 * ms-foundry — Microsoft Foundry (Azure OpenAI) custom provider for pi.
 *
 * Project-local extension: lives at `.pi/extensions/ms-foundry/index.ts`.
 * Loads automatically once the project is trusted; run `/reload` after edits.
 *
 * Configuration files (JSON):
 *   Global (personal defaults):  ~/.pi/agent/ms-foundry-models.json
 *   Project (team / overrides):  .pi/ms-foundry-models.json
 *
 * Merge semantics: per-id union — a project model entry replaces the global
 * entry with the same id; provider-level `baseUrl`/`name` come from the
 * project file when set, else fall back to the global file.
 *
 * Schema:
 *   {
 *     "name":     "Microsoft Foundry",            // optional display name
 *     "baseUrl":  "https://.../openai/v1",        // required OpenAI-compatible base URL
 *     "models": [
 *       {
 *         "id": "gpt-4o",                         // REQUIRED: Azure deployment name
 *         "name": "GPT-4o",                       // optional, defaults to id
 *         "reasoning": false,                     // optional, default false
 *         "input": ["text", "image"],             // optional, default ["text"]
 *         "contextWindow": 128000,                // optional, default 128000
 *         "maxTokens": 16384,                     // optional, default 16384
 *         "thinkingLevelMap": { ... },            // optional
 *         "compat": { ... },                      // optional OpenAI-compat flags
 *         "samplingParams": { ... }               // optional, merged into requests
 *       }
 *     ]
 *   }
 *
 * Cost metadata is intentionally zero — usage is tracked in tokens only.
 *
 * Auth: run `/login ms-foundry` once; the key is stored in
 * `~/.pi/agent/auth.json` and sent as the `api-key` HTTP header
 * (Azure data-plane key auth; Bearer is only for Entra ID, which is not used).
 *
 * Streaming: OpenAI Chat Completions against `{baseUrl}/chat/completions`.
 * The configured baseUrl must end at `/openai/v1` (not `/chat/completions`).
 *
 * Missing global file → provider not registered. Malformed JSON → warned
 * about, file skipped, whatever else loaded still works.
 */

import {
	type Api,
	type Model,
	createProvider,
	openAICompletionsApi,
} from "@earendil-works/pi-ai";
import { CONFIG_DIR_NAME, getAgentDir } from "@earendil-works/pi-coding-agent";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { existsSync, readFileSync } from "node:fs";
import { join } from "node:path";

const PROVIDER_ID = "ms-foundry";
const PROVIDER_NAME = "Microsoft Foundry";
const CONFIG_FILENAME = "ms-foundry-models.json";

type Compat = Model<"openai-completions">["compat"];

interface FoundryModelConfig {
	/** Azure deployment name — sent as the request's model field. */
	id: string;
	name?: string;
	reasoning?: boolean;
	thinkingLevelMap?: Model<Api>["thinkingLevelMap"];
	input?: ("text" | "image")[];
	contextWindow?: number;
	maxTokens?: number;
	samplingParams?: Record<string, unknown>;
	compat?: Compat;
}

interface FoundryConfig {
	name?: string;
	baseUrl?: string;
	models?: FoundryModelConfig[];
}

interface LoadedConfig {
	config?: FoundryConfig;
	error?: string;
}

function readConfigFile(path: string): LoadedConfig {
	if (!existsSync(path)) return {};
	try {
		const parsed: unknown = JSON.parse(readFileSync(path, "utf8"));
		if (typeof parsed !== "object" || parsed === null || Array.isArray(parsed)) {
			return { error: `${path}: expected a JSON object` };
		}
		return { config: parsed as FoundryConfig };
	} catch (error) {
		return { error: `${path}: ${error instanceof Error ? error.message : String(error)}` };
	}
}

function mergeConfigs(
	global: FoundryConfig | undefined,
	project: FoundryConfig | undefined,
): FoundryConfig {
	const models = new Map<string, FoundryModelConfig>();
	for (const model of global?.models ?? []) {
		if (model?.id) models.set(model.id, model);
	}
	for (const model of project?.models ?? []) {
		if (model?.id) models.set(model.id, model);
	}
	return {
		name: project?.name ?? global?.name,
		baseUrl: project?.baseUrl ?? global?.baseUrl,
		models: [...models.values()],
	};
}

// Defaults mirror pi's own provider-composer modelFromJson().
function toModel(config: FoundryModelConfig, baseUrl: string): Model<"openai-completions"> {
	return {
		id: config.id,
		name: config.name ?? config.id,
		api: "openai-completions",
		provider: PROVIDER_ID,
		baseUrl,
		reasoning: config.reasoning ?? false,
		thinkingLevelMap: config.thinkingLevelMap,
		input: config.input ?? ["text"],
		cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
		contextWindow: config.contextWindow ?? 128000,
		maxTokens: config.maxTokens ?? 16384,
		samplingParams: config.samplingParams,
		headers: undefined,
		compat: config.compat,
	};
}

export default function msFoundryProvider(pi: ExtensionAPI) {
	const global = readConfigFile(join(getAgentDir(), CONFIG_FILENAME));
	const project = readConfigFile(join(process.cwd(), CONFIG_DIR_NAME, CONFIG_FILENAME));

	for (const error of [global.error, project.error]) {
		if (error) console.warn(`[ms-foundry] ${error}`);
	}

	const merged = mergeConfigs(global.config, project.config);

	if (!merged.baseUrl?.trim()) {
		console.warn(
			`[ms-foundry] no "baseUrl" configured in ${CONFIG_FILENAME}; provider not registered`,
		);
		return;
	}
	if (merged.models.length === 0) {
		console.warn(`[ms-foundry] no models configured in ${CONFIG_FILENAME}; provider not registered`);
		return;
	}

	const baseUrl = merged.baseUrl.trim().replace(/\/+$/, "");

	pi.registerProvider(
		createProvider({
			id: PROVIDER_ID,
			name: merged.name ?? PROVIDER_NAME,
			baseUrl,
			auth: {
				apiKey: {
					name: "Microsoft Foundry API key",
					async login(interaction) {
						const key = await interaction.prompt({
							type: "secret",
							message: "Microsoft Foundry API key",
						});
						return { type: "api_key", key };
					},
					async resolve({ credential }) {
						if (!credential?.key) return undefined;
						return {
							// openai-completions requires auth.apiKey to initialize its
							// client. The Azure-specific header is still needed for
							// data-plane key authentication.
							auth: {
								apiKey: credential.key,
								headers: { "api-key": credential.key },
							},
							source: "stored API key",
						};
					},
				},
			},
			models: merged.models.map((model) => toModel(model, baseUrl)),
			api: openAICompletionsApi(),
		}),
	);
}
