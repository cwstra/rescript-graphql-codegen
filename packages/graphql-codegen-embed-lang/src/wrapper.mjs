import { normalizeInstanceOrArray } from "@graphql-codegen/plugin-helpers";
import { generate, loadCodegenConfig } from "@graphql-codegen/cli";
import { isValidPath } from "@graphql-tools/utils";
import isGlob from "is-glob";
import mm from "micromatch";
import { isAbsolute, resolve } from 'path'

export const testPattern = (relativePath, pattern) =>
  mm.isMatch(relativePath, pattern)

export const getSchemaPatterns = (config) => {
  const patterns = normalizeInstanceOrArray(config.schema).filter(
    (s) => isGlob(s) || isValidPath(s),
  );
  const affirmative = [];
  const negated = [];
  patterns.forEach((pattern) => {
    const scan = mm.scan(pattern)
    if (scan.negated)
      // Chop off the negated prefix; we'll be testing these as though they
      // were affirmative in the watcher
      negated.push(pattern.slice(scan.prefix.length));
    else affirmative.push(pattern);
  });
  return {
    affirmative,
    negated
  };
};

export const getCodegenConfig = async (configFilePath) => {
  const result = await loadCodegenConfig({ configFilePath })
  if (result) return [result.filepath, result.config]
}


export const getGeneratesEntry = mainConfig => mainConfig.config?.ppxGenerates;

// RUN

export const runBase = (
  mainConfig,
) =>
  generate(
    mainConfig,
    true,
  );

export const runDocument = (
  { mainConfig, generatesEntry },
  sourceFilePath,
  documents,
) =>
  generate(
    {
      ...mainConfig,
      generates: {
        [sourceFilePath]: {
          ...generatesEntry,
          documents,
        },
      },
    },
    false,
  );
