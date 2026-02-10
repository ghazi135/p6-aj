/**
 * Semantic-release config: version from Conventional Commits on main.
 * - feat:        → minor bump (1.0.0 → 1.1.0)
 * - fix:         → patch bump (1.0.0 → 1.0.1)
 * - feat!: / BREAKING CHANGE: → major bump (1.0.0 → 2.0.0)
 * - docs:, chore:, style:, etc. → no new release
 */
module.exports = {
  plugins: [
    // Support Conventional Commits breaking syntax (`feat!: ...`) without
    // pulling in extra preset packages in CI.
    [
      '@semantic-release/commit-analyzer',
      {
        preset: 'angular',
        releaseRules: [
          { type: 'feat', release: 'minor' },
          { type: 'fix', release: 'patch' },
          { type: 'perf', release: 'patch' },
          { breaking: true, release: 'major' },
          { type: 'BREAKING CHANGE', release: 'major' },
        ],
        parserOpts: {
          noteKeywords: ['BREAKING CHANGE', 'BREAKING CHANGES', 'BREAKING'],
          // type: subject  OR  BREAKING CHANGE: subject
          headerPattern: /^(BREAKING CHANGE|\w+)(?:\(([^)]+)\))?!?: (.+)$/,
          headerCorrespondence: ['type', 'scope', 'subject'],
          breakingHeaderPattern: /^(\w+)(?:\(([^)]+)\))?!: (.+)$/,
          breakingHeaderCorrespondence: ['type', 'scope', 'subject'],
        },
      },
    ],
    [
      '@semantic-release/release-notes-generator',
      {
        preset: 'angular',
        parserOpts: {
          noteKeywords: ['BREAKING CHANGE', 'BREAKING CHANGES', 'BREAKING'],
          headerPattern: /^(\w+)(?:\(([^)]+)\))?!?: (.+)$/,
          headerCorrespondence: ['type', 'scope', 'subject'],
          breakingHeaderPattern: /^(\w+)(?:\(([^)]+)\))?!: (.+)$/,
          breakingHeaderCorrespondence: ['type', 'scope', 'subject'],
        },
      },
    ],
    // Update version in build.gradle
    [
      '@semantic-release/exec',
      {
        prepareCmd: "sed -i \"s/^version = '.*'/version = '${nextRelease.version}'/\" build.gradle",
      },
    ],
    // Commit the updated build.gradle
    [
      '@semantic-release/git',
      {
        assets: ['build.gradle'],
        message: 'chore(release): ${nextRelease.version} [skip ci]',
      },
    ],
    '@semantic-release/github',
  ],
};
