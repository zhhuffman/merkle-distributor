# @CryptoUnico/merkle-distributor

<a href="https://snyk.io/test/github/CryptoUnico/merkle-distributor?targetFile=package.json"><img src="https://snyk.io/test/github/CryptoUnico/merkle-distributor/badge.svg?targetFile=package.json" alt="Known Vulnerabilities" data-canonical-src="https://snyk.io/test/github/CryptoUnico/merkle-distributor?targetFile=package.json" style="max-width:100%;"></a>

# Local Development

## High-Level Overview of Specification Updates

* Update: MerkleDistributor.sol

* Terminal Commands:
	- install dependencies ('yarn'), compile ('yarn waffle' // 'yarn compile'), test ('yarn mocha'), prepublish only ('yarn test')
	- generate merkle root: example ('yarn run ts-node scripts/generate-merkle-root.ts --input scripts/example.json')

* Update: scripts/result.json to the output generated from generate merkle root: example
	- note: if dev (that's you) not on whitelist, then test with inclusion, then remove on new root generation and cross your fingers and hope to gawd that the new root works when the time comes for production.

* Run: yarn run ts-node scripts/verify-merkle-root.ts --input scripts/result.json
	- if fail: ensure that the result.json is updated to the merkle root that aligns with input example and not from the default configuration.

* Run: to-kv-input (with the inputs listed below)
	- Claims Tree
	- Chain-ID
	- Token: Cloudflare API token
	- Account Identifier: Cloudflare account identifier
	- Namespace Identifier: Cloudflare KV namespace identifier 

### README.md and MerkleDistributor.sol created by [Uni](https://Learn-Solidity.com)
