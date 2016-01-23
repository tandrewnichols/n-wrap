var spawn = require('child_process').spawn;
var spawnSync = require('spawn-sync');
var strip = require('strip-ansi');
var opted = require('opted');

// Varity simplifies argument reshifting for functions
// that accept a variety of arguments.
var varity = require('varity');

// Strip ansi escape sequences, trim lines, and remove empty lines
// for output that doesn't need to be logged "as is"
var sanitizeOutput = function(output) {
  return strip(output).split('\n').map(function(line) {
    return line.trim();
  }).filter(function(line) {
    return Boolean(line);
  }).join('\n');
};

// Put all the spawn args together in the right order
var buildArgs = function(subcmd, version, config, opts, args) {
  var spawnArgs = [];
  // If this is an io.js procdeure, add io as the first argument
  if (config.io) {
    spawnArgs.push('io');
  }
  
  // If there's a command (rm, ls, etc.), add that next
  if (subcmd) {
    spawnArgs.push(subcmd);
  }

  // Push any flags next
  if (opts) {
    // opted converts an object to CLI flags
    spawnArgs = spawnArgs.concat(opted(opts));
  }

  // Add the version at the end
  if (version) {
    spawnArgs.push(version);
  }

  // Followed by any pre-supplied arguments (which should only be for "use")
  return spawnArgs.concat(args);
};

// Async spawn
var async = function(args, config, cb, fn) {
  var child;
  var stdout = '';
  var stderr = '';
  var err = '';

  // Use stdio: inherit for use/as, since you want the output
  // exactly as is, including color and spacing
  if (config.stdio) {
    child = spawn('n', args, { stdio: 'inherit' });
  } else {
    // Setup stdout and stderr handlers
    child = spawn('n', args);
    child.stdout.on('data', function(data) {
      stdout += data.toString(); 
    });
    child.stderr.on('data', function(data) {
      stderr += data.toString(); 
    });
  }

  // Add error and close handlers for both versions of spawn
  child.on('error', function(e) {
    err = e;
  });
  child.on('close', function() {
    // Choose error first, then stderr if present
    err = err || (stderr ? new Error(stderr) : null);
    // Sanitize output (empty string if stdio is inherit)
    var output = sanitizeOutput(stdout);
    // Run any postprocessing on the output (i.e. ls should return an array)
    output = cb ? cb(output) : output;
    fn(err, output);
  });
};

// Sync spawn
var sync = function(args, config, cb) {
  // Call spawnSync with stdio if necessary
  var res = config.stdio ? spawnSync('n', args, { stdio: 'inherit' }) : spawnSync('n', args);
  // Throw if there was an error
  if (res.status > 0) {
    throw res.error || new Error(res.stderr || 'Unknown error running n ' + args.join(' '));
  } else {
    // Sanitize the output and pass it to postprocessing (or return)
    var output = sanitizeOutput(res.stdout ? res.stdout.toString() : '');
    return cb ? cb(output) : output;
  }
};

/**
 * createSpawn
 *
 *  Wrapper to create a function that will spawn the various n commands
 *
 *  @param {String} [subcmd] - The n command to run
 *  @param {Object} [config] - Pass io: true for io.js and stdio: true to use current stdout/stderr
 *  @param {Function} [cb] - A post-processing function that transforms and returns stdout
 */
var createSpawn = function(subcmd, config,  cb) {
  config = config || {};
  // The varity invocation here just dictates that this function takes:
  //    1. A string
  //    2. An array, which will be set to [] if not passed
  //    3. An object
  //    4. A function
  //
  // If any of those arguments are omitted, the others will be shifted accordingly
  return varity('s+aof', function(version, args, opts, fn) {
    // Get the args for the child process
    args = buildArgs(subcmd, version, config, opts, args);
    // Invoke the sync or async spawn
    return typeof fn === 'function' ? async(args, config, cb, fn) : sync(args, config, cb);
  });
};

// Postprocessor for ls/list to remove extra space and
// the current node indicator ("o"), and return the versions
// as a list
var sanitizeList = function(output) {
  return output.replace(/[^\d\n\.]/g, '').split('\n');  
};

// Create the API
var n = createSpawn();
n.rm = n.remove = createSpawn('rm');
n.bin = n.which = createSpawn('bin');
n.use = n.as = createSpawn('use', { stdio: true });
n.ls = n.list = createSpawn('ls', {}, sanitizeList);

n.io = createSpawn(null, { io: true });
n.io.rm = n.io.remove = createSpawn('rm', { io: true });
n.io.bin = n.io.which = createSpawn('bin', { io: true });
n.io.use = n.io.as = createSpawn('use', { io: true, stdio: true });
n.io.ls = n.io.list = createSpawn('ls', { io: true }, sanitizeList);

module.exports = n;
