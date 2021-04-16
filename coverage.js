const { runCoverage } = require('@openzeppelin/test-environment');

async function main () {
  await runCoverage(
    ['Migration.sol'],
    "sh truffle.sh compile",
    ["./node_modules/.bin/truffle", "test"]
  );
}

main().catch(e => {
  console.error(e);
  process.exit(1);
});