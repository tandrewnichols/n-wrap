var spawn = require('child_process').spawn;
var spawnSync = require('spawn-sync');
var strip = require('strip-ansi');
var opted = require('opted');

// Varity simplifies argument reshifting for functions
// that accept a variety of arguments.
var varity = require('varity');

var sanitizeOutput = function(output) {
  return strip(output).split('\n').map(function(line) {
    return line.trim();
  }).filter(function(line) {
    return Boolean(line);
  }).join('\n');
};

var createSpawn = function(subcmd, io,  cb) {
  return varity('s+aof', function(version, args, opts, fn) {
    var localArgs = [];
    if (io) {
      localArgs.push('io');
    }
    
    if (subcmd) {
      localArgs.push(subcmd);
    }

    if (opts) {
      localArgs = localArgs.concat(opted(opts));
    }

    if (version) {
      localArgs.push(version);
    }

    args = localArgs.concat(args);
    if (typeof fn === 'function') {
      var child = spawn('n', args);
      var stdout = '';
      var stderr = '';
      var err = '';
      child.stdout.on('data', function(data) {
        stdout += data.toString(); 
      });
      child.stderr.on('data', function(data) {
        stderr += data.toString(); 
      });
      child.on('error', function(e) {
        err = e;
      });
      child.stdout.on('close', function() {
        err = err || (stderr ? new Error(stderr) : null);
        var output = sanitizeOutput(stdout);
        output = cb ? cb(output) : output;
        fn(err, output);
      });
    } else {
      var res = spawnSync('n', args);
      if (res.status > 0) {
        throw res.error || new Error(res.stderr || 'Unknown error running n ' + args.join(' '));
      } else {
        var output = sanitizeOutput(res.stdout.toString());
        return cb ? cb(output) : output;
      }
    }
  });
};

var sanitizeList = function(output) {
  return output.replace(/[^\d\n\.]/g, '').split('\n');  
};

var n = createSpawn();
n.rm = n.remove = createSpawn('rm');
n.bin = n.which = createSpawn('bin');
n.use = n.as = createSpawn('use');
n.ls = n.list = createSpawn('ls', null, sanitizeList);

n.io = createSpawn(null, true);
n.io.rm = n.io.remove = createSpawn('rm', true);
n.io.bin = n.io.which = createSpawn('bin', true);
n.io.use = n.io.as = createSpawn('use', true);
n.io.ls = n.io.list = createSpawn('ls', true, sanitizeList);

module.exports = n;
