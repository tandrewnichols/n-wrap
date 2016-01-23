[![Build Status](https://travis-ci.org/tandrewnichols/n-wrap.png)](https://travis-ci.org/tandrewnichols/n-wrap) [![downloads](http://img.shields.io/npm/dm/n-wrap.svg)](https://npmjs.org/package/n-wrap) [![npm](http://img.shields.io/npm/v/n-wrap.svg)](https://npmjs.org/package/n-wrap) [![Code Climate](https://codeclimate.com/github/tandrewnichols/n-wrap/badges/gpa.svg)](https://codeclimate.com/github/tandrewnichols/n-wrap) [![Test Coverage](https://codeclimate.com/github/tandrewnichols/n-wrap/badges/coverage.svg)](https://codeclimate.com/github/tandrewnichols/n-wrap) [![dependencies](https://david-dm.org/tandrewnichols/n-wrap.png)](https://david-dm.org/tandrewnichols/n-wrap)

# n-wrap

Node wrapper for the n binary manager

## Installation

`npm install --save n-wrap`

## Summary

I prefer [n](https://github.com/tj/n) to [nvm](https://github.com/creationix/nvm) for managing node versions, but there's no _good_ node api for it, so I wrote this as a wrapper for the binary. It works either synchronously or asynchronously and implements all of n's currect functionality (@v2.1.0). All the functions look basically just like the CLI commands, so it shouldn't be much of a leap to figure out how things work. With all of these functions, pass a callback as the final argument to use async. All functions return (a cleaned up version of) stdout (or pass it via callback), which is probably not that useful in most cases.

_Note: This library uses the [spawn-sync](https://github.com/ForbesLindesay/spawn-sync) module which is a polyfill for `child_process.spawnSync` that uses [thread-sleep](https://github.com/ForbesLindesay/thread-sleep), which means that it may not work (or work efficiently) on every platform. If you're in doubt, just use the asynchronous verion._

## Usage

```js
var n = require('n-wrap');
```

## API

### n

Invoke `n` with a version to install or switch to that version. These are passed directly to the command line, so things like `latest`, `lts`, etc. will still work.

```js
var stdout = n('4.2.4');
n('4.2.4', function(err, stdout) {

});
```

### remove/rm

Remove an install binary.

```js
var stdout = n.remove('4.0.0');
n.remove('4.0.0', function(err, stdout) {

});
```

### bin/which

Get the path to a binary

```js
var stdout = n.bin('4.2.4');
n.bin('4.2.4', function(err, path) {

});
```

### use/as

Invoke the node REPL or a node script with a particular binary

```js
var stdout = n.use('4.2.4')

## Contributing

Please see [the contribution guidelines](CONTRIBUTING.md).
