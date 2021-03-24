#!/usr/bin/env node
'use strict';
/**
* @file sol-osx
* @copyright Sam Bacha 2021
* @license MIT
* @summary command line interface tool
*/

const os = require('os');
const path = require('path');
const spawn = require('child_process').spawn;
const fs = require('fs');
const resolve = require('resolve').sync;
const glob = require('glob');
const async = require('async');

const VERSION = require('./package.json').version;
const LOCATION = __filename;

// TODO
const GLOB_OPTION = '--glob=';

function getNativeBinary() {
  const arch = {
    'arm64': 'arm64',
    'x64': 'amd64',
  }[os.arch()];
  /** Filter the platform based on the platforms that are build/included. */
  const platform = {
    'darwin': 'darwin',
    'linux': 'linux',
  }[os.platform()];
  const extension = {
    'darwin': '',
    'linux': '',
  }[os.platform()];

  if (arch == undefined || platform == undefined) {
    console.error(`FATAL: Your platform/architecture combination ${
      os.platform()} - ${os.arch()} is not yet supported.
    See instructions at https://github.com/sambacha/solidity-osx/blob/master/README.md.`);
    return Promise.resolve(1);
  }

  const binary =
    path.join(__dirname, `solidity-${platform}_${arch}${extension}`);
  return binary;
}

function main(args) {
  const binary = getNativeBinary();
  const ps = spawn(binary, args, { stdio: 'inherit' });


  if (args.find(a => a === '-version' || a === '--version')) {
    /** version of the tool, not the compiler */
    console.log(`solidity-osx ${VERSION} at ${LOCATION}`);
    args = ['--version'];
  }

  function shutdown() {
    ps.kill("SIGTERM")
    process.exit();
  }

  process.on("SIGINT", shutdown);
  process.on("SIGTERM", shutdown);

  ps.on('close', e => process.exitCode = e);
}

if (require.main === module) {
  main(process.argv.slice(2));
}

module.exports = {
  getNativeBinary,
};
