const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

function runCommand(command) {
  try {
    const output = execSync(command, { encoding: 'utf-8' });
    return { success: true, output };
  } catch (error) {
    return { success: false, error: error.message };
  }
}

function checkNodeVersion() {
  const version = process.version;
  console.log(`Node.js Version: ${version}`);
  
  // Check if version is compatible
  const majorVersion = parseInt(version.replace('v', '').split('.')[0]);
  if (majorVersion < 16) {
    console.error("❌ Node.js version is too low. Recommended: 16+");
    return false;
  }
  return true;
}

function checkNpmInstallation() {
  const npmCheck = runCommand('npm --version');
  if (npmCheck.success) {
    console.log(`✅ NPM Version: ${npmCheck.output.trim()}`);
    return true;
  }
  console.error("❌ NPM is not installed or not in PATH");
  return false;
}

function checkHardhatInstallation() {
  const hardhatCheck = runCommand('npx hardhat --version');
  if (hardhatCheck.success) {
    console.log(`✅ Hardhat Version: ${hardhatCheck.output.trim()}`);
    return true;
  }
  console.error("❌ Hardhat is not installed");
  return false;
}

function checkProjectStructure() {
  const projectPaths = [
    'contracts/VotingSystem.sol',
    'scripts/deploy.js',
    'frontend/package.json',
    'frontend/src/App.js'
  ];

  let allFilesExist = true;
  projectPaths.forEach(filePath => {
    const fullPath = path.join(__dirname, '..', filePath);
    if (fs.existsSync(fullPath)) {
      console.log(`✅ File exists: ${filePath}`);
    } else {
      console.error(`❌ Missing file: ${filePath}`);
      allFilesExist = false;
    }
  });

  return allFilesExist;
}

function checkContractCompilation() {
  const compileCheck = runCommand('npx hardhat compile');
  if (compileCheck.success) {
    console.log("✅ Contract Compilation Successful");
    return true;
  }
  console.error("❌ Contract Compilation Failed");
  return false;
}

function main() {
  console.log("=== Blockchain Development Environment Check ===");
  
  const checks = [
    checkNodeVersion(),
    checkNpmInstallation(),
    checkHardhatInstallation(),
    checkProjectStructure(),
    checkContractCompilation()
  ];

  const allChecksPassed = checks.every(check => check === true);

  if (allChecksPassed) {
    console.log("\n🎉 All System Checks Passed!");
    console.log("You're ready to develop your Blockchain Application!");
  } else {
    console.error("\n❌ Some System Checks Failed. Please review the errors above.");
  }
}

main();
