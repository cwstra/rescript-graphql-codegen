const camelcase = require("camelcase")

exports.pascalCase = str => camelcase(str, { pascalCase: true })
