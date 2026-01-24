module.exports = {
  root: true,
  env: { browser: true, es2020: true },
  extends: [
    'eslint:recommended',
    'plugin:@typescript-eslint/recommended',
    'plugin:react-hooks/recommended',
  ],
  ignorePatterns: ['dist', '.eslintrc.cjs'],
  parser: '@typescript-eslint/parser',
  plugins: ['react-refresh'],
  rules: {
    'react-refresh/only-export-components': [
      'warn',
      { allowConstantExport: true },
    ],
    // Verbiete console.log in Produktion (warn statt error für Übergangszeit)
    'no-console': ['warn', { allow: ['warn', 'error'] }],
    // Erlaube unused vars mit _ prefix
    '@typescript-eslint/no-unused-vars': ['warn', { argsIgnorePattern: '^_' }],
    // Erlaube any Type (für Übergangszeit)
    '@typescript-eslint/no-explicit-any': 'off',
  },
};
