module.exports = {
  env: {
    es6: true,
    node: true,
  },
  parserOptions: {
    ecmaVersion: 2020,
  },
  extends: ["eslint:recommended"],
  rules: {
    "no-restricted-globals": ["error", "name", "length"],
    "prefer-arrow-callback": "error",
    "max-len": "off",
    "quotes": ["error", "double", { "allowTemplateLiterals": true }],
    "eol-last": ["error", "always"],
  },
};
