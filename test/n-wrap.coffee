sinon = require 'sinon'
chalk = require 'chalk'

describe 'n-wrap', ->
  Given -> @child =
    on: sinon.stub()
    stdout:
      on: sinon.stub()
    stderr:
      on: sinon.stub()
  Given -> @output = """
        #{chalk.green('foo')}: blah   
    bar: #{chalk.red('huzzah')}
  """
  Given -> @versions = chalk.green('   2.1.2\n3.4.1\no 3.9.9')
  Given -> @versionsArr = ['2.1.2', '3.4.1', '3.9.9']
  Given -> @clean = 'foo: blah\nbar: huzzah'
  Given -> @syncRes =
    stdout: @output
    stderr: ''
    status: 0
  Given -> @cp =
    spawn: sinon.stub()
  Given -> @spawnSync = sinon.stub()

  Given -> @subject = require('proxyquire').noCallThru() '../lib/n-wrap',
    child_process: @cp
    'spawn-sync': @spawnSync

  Given -> @cb = sinon.stub()

  context 'node', ->
    describe 'exported function', ->
      context 'async', ->
        Given -> @cp.spawn.withArgs('n', ['0.10']).returns @child
        Given -> @child.stdout.on.withArgs('data').callsArgWith 1, @output
        Given -> @child.stdout.on.withArgs('close').callsArg 1
        When -> @subject '0.10', @cb
        Then -> @cb.calledWith(null, @clean).should.be.true()

      context 'sync', ->
        Given -> @spawnSync.withArgs('n', ['0.10']).returns @syncRes
        Then -> @subject('0.10').should.eql @clean
      
    describe '.install', ->
      context 'async', ->
        context 'no error', ->
          Given -> @cp.spawn.withArgs('n', ['0.10']).returns @child
          Given -> @child.stdout.on.withArgs('data').callsArgWith 1, @output
          Given -> @child.stdout.on.withArgs('close').callsArg 1
          When -> @subject '0.10', @cb
          Then -> @cb.calledWith(null, @clean).should.be.true()

        context 'error spawning', ->
          Given -> @cp.spawn.withArgs('n', ['0.10']).returns @child
          Given -> @child.on.withArgs('error').callsArgWith 1, 'stuff happened'
          Given -> @child.stdout.on.withArgs('close').callsArg 1
          When -> @subject '0.10', @cb
          Then -> @cb.calledWith('stuff happened').should.be.true()

        context 'error with command', ->
          Given -> @cp.spawn.withArgs('n', ['0.10']).returns @child
          Given -> @child.stderr.on.withArgs('data').callsArgWith 1, 'stuff happened'
          Given -> @child.stdout.on.withArgs('close').callsArg 1
          When -> @subject '0.10', @cb
          Then -> @cb.calledWith(sinon.match.instanceOf(Error)).should.be.true()

        context 'with both error and stderr should return the error', ->
          Given -> @cp.spawn.withArgs('n', ['0.10']).returns @child
          Given -> @child.stderr.on.withArgs('data').callsArgWith 1, 'other stuff happened'
          Given -> @child.on.withArgs('error').callsArgWith 1, 'stuff happened'
          Given -> @child.stdout.on.withArgs('close').callsArg 1
          When -> @subject '0.10', @cb
          Then -> @cb.calledWith('stuff happened').should.be.true()
          
      context 'sync', ->
        context 'no error', ->
          Given -> @spawnSync.withArgs('n', ['0.10']).returns @syncRes
          Then -> @subject('0.10').should.eql @clean

        context 'error', ->
          context 'with an error object', ->
            Given -> @syncRes.status = 1
            Given -> @syncRes.error = new Error('foo')
            Given -> @spawnSync.withArgs('n', ['0.10']).returns @syncRes
            Then -> ( => @subject('0.10') ).should.throw('foo')

          context 'with no error object but a stderr', ->
            Given -> @syncRes.status = 1
            Given -> @syncRes.stderr = 'foo'
            Given -> @spawnSync.withArgs('n', ['0.10']).returns @syncRes
            Then -> ( => @subject('0.10') ).should.throw('foo')

          context 'with no error or stderr', ->
            Given -> @syncRes.status = 1
            Given -> @spawnSync.withArgs('n', ['0.10']).returns @syncRes
            Then -> ( => @subject('0.10') ).should.throw('Unknown error running n 0.10')

    describe '.remove', ->
      context 'async', ->
        Given -> @cp.spawn.withArgs('n', ['rm', '0.10']).returns @child
        Given -> @child.stdout.on.withArgs('data').callsArgWith 1, @output
        Given -> @child.stdout.on.withArgs('close').callsArg 1
        When -> @subject.remove '0.10', @cb
        Then -> @cb.calledWith(null, @clean).should.be.true()
        
      context 'sync', ->
        Given -> @spawnSync.withArgs('n', ['rm', '0.10']).returns @syncRes
        Then -> @subject.remove('0.10').should.eql @clean

    describe '.rm', ->
      context 'async', ->
        Given -> @cp.spawn.withArgs('n', ['rm', '0.10']).returns @child
        Given -> @child.stdout.on.withArgs('data').callsArgWith 1, @output
        Given -> @child.stdout.on.withArgs('close').callsArg 1
        When -> @subject.rm '0.10', @cb
        Then -> @cb.calledWith(null, @clean).should.be.true()
        
      context 'sync', ->
        Given -> @spawnSync.withArgs('n', ['rm', '0.10']).returns @syncRes
        Then -> @subject.rm('0.10').should.eql @clean

    describe '.bin', ->
      context 'async', ->
        Given -> @cp.spawn.withArgs('n', ['bin', '0.10']).returns @child
        Given -> @child.stdout.on.withArgs('data').callsArgWith 1, @output
        Given -> @child.stdout.on.withArgs('close').callsArg 1
        When -> @subject.bin '0.10', @cb
        Then -> @cb.calledWith(null, @clean).should.be.true()
        
      context 'sync', ->
        Given -> @spawnSync.withArgs('n', ['bin', '0.10']).returns @syncRes
        Then -> @subject.bin('0.10').should.eql @clean

    describe '.which', ->
      context 'async', ->
        Given -> @cp.spawn.withArgs('n', ['bin', '0.10']).returns @child
        Given -> @child.stdout.on.withArgs('data').callsArgWith 1, @output
        Given -> @child.stdout.on.withArgs('close').callsArg 1
        When -> @subject.which '0.10', @cb
        Then -> @cb.calledWith(null, @clean).should.be.true()
        
      context 'sync', ->
        Given -> @spawnSync.withArgs('n', ['bin', '0.10']).returns @syncRes
        Then -> @subject.which('0.10').should.eql @clean

    describe '.use', ->
      context 'async', ->
        Given -> @cp.spawn.withArgs('n', ['use', '0.10']).returns @child
        Given -> @child.stdout.on.withArgs('data').callsArgWith 1, @output
        Given -> @child.stdout.on.withArgs('close').callsArg 1
        When -> @subject.use '0.10', @cb
        Then -> @cb.calledWith(null, @clean).should.be.true()
        
      context 'sync', ->
        Given -> @spawnSync.withArgs('n', ['use', '0.10']).returns @syncRes
        Then -> @subject.use('0.10').should.eql @clean

    describe '.as', ->
      context 'async', ->
        Given -> @cp.spawn.withArgs('n', ['use', '0.10']).returns @child
        Given -> @child.stdout.on.withArgs('data').callsArgWith 1, @output
        Given -> @child.stdout.on.withArgs('close').callsArg 1
        When -> @subject.as '0.10', @cb
        Then -> @cb.calledWith(null, @clean).should.be.true()
        
      context 'sync', ->
        Given -> @spawnSync.withArgs('n', ['use', '0.10']).returns @syncRes
        Then -> @subject.as('0.10').should.eql @clean

    describe '.list', ->
      context 'async', ->
        Given -> @cp.spawn.withArgs('n', ['ls']).returns @child
        Given -> @child.stdout.on.withArgs('data').callsArgWith 1, @versions
        Given -> @child.stdout.on.withArgs('close').callsArg 1
        When -> @subject.list @cb
        Then -> @cb.calledWith(null, @versionsArr).should.be.true()
        
      context 'sync', ->
        Given -> @syncRes.stdout = @versions
        Given -> @spawnSync.withArgs('n', ['ls']).returns @syncRes
        Then -> @subject.ls().should.eql @versionsArr

    describe '.ls', ->
      context 'async', ->
        Given -> @cp.spawn.withArgs('n', ['ls']).returns @child
        Given -> @child.stdout.on.withArgs('data').callsArgWith 1, @versions
        Given -> @child.stdout.on.withArgs('close').callsArg 1
        When -> @subject.ls @cb
        Then -> @cb.calledWith(null, @versionsArr).should.be.true()
        
      context 'sync', ->
        Given -> @syncRes.stdout = @versions
        Given -> @spawnSync.withArgs('n', ['ls']).returns @syncRes
        Then -> @subject.ls().should.eql @versionsArr

  context 'io', ->
    describe 'exported function', ->
      context 'async', ->
        Given -> @cp.spawn.withArgs('n', ['io', '0.10']).returns @child
        Given -> @child.stdout.on.withArgs('data').callsArgWith 1, @output
        Given -> @child.stdout.on.withArgs('close').callsArg 1
        When -> @subject.io '0.10', @cb
        Then -> @cb.calledWith(null, @clean).should.be.true()

      context 'sync', ->
        Given -> @spawnSync.withArgs('n', ['io', '0.10']).returns @syncRes
        Then -> @subject.io('0.10').should.eql @clean
      
    describe '.install', ->
      context 'async', ->
        context 'no error', ->
          Given -> @cp.spawn.withArgs('n', ['io', '0.10']).returns @child
          Given -> @child.stdout.on.withArgs('data').callsArgWith 1, @output
          Given -> @child.stdout.on.withArgs('close').callsArg 1
          When -> @subject.io '0.10', @cb
          Then -> @cb.calledWith(null, @clean).should.be.true()

        context 'error spawning', ->
          Given -> @cp.spawn.withArgs('n', ['io', '0.10']).returns @child
          Given -> @child.on.withArgs('error').callsArgWith 1, 'stuff happened'
          Given -> @child.stdout.on.withArgs('close').callsArg 1
          When -> @subject.io '0.10', @cb
          Then -> @cb.calledWith('stuff happened').should.be.true()

        context 'error with command', ->
          Given -> @cp.spawn.withArgs('n', ['io', '0.10']).returns @child
          Given -> @child.stderr.on.withArgs('data').callsArgWith 1, 'stuff happened'
          Given -> @child.stdout.on.withArgs('close').callsArg 1
          When -> @subject.io '0.10', @cb
          Then -> @cb.calledWith(sinon.match.instanceOf(Error)).should.be.true()

        context 'with both error and stderr should return the error', ->
          Given -> @cp.spawn.withArgs('n', ['io', '0.10']).returns @child
          Given -> @child.stderr.on.withArgs('data').callsArgWith 1, 'other stuff happened'
          Given -> @child.on.withArgs('error').callsArgWith 1, 'stuff happened'
          Given -> @child.stdout.on.withArgs('close').callsArg 1
          When -> @subject.io '0.10', @cb
          Then -> @cb.calledWith('stuff happened').should.be.true()
          

      context 'sync', ->
        context 'no error', ->
          Given -> @spawnSync.withArgs('n', ['io', '0.10']).returns @syncRes
          Then -> @subject.io('0.10').should.eql @clean

        context 'error', ->
          context 'with an error object', ->
            Given -> @syncRes.status = 1
            Given -> @syncRes.error = new Error('foo')
            Given -> @spawnSync.withArgs('n', ['io', '0.10']).returns @syncRes
            Then -> ( => @subject.io('0.10') ).should.throw('foo')

          context 'with no error object but a stderr', ->
            Given -> @syncRes.status = 1
            Given -> @syncRes.stderr = 'foo'
            Given -> @spawnSync.withArgs('n', ['io', '0.10']).returns @syncRes
            Then -> ( => @subject.io('0.10') ).should.throw('foo')

          context 'with no error or stderr', ->
            Given -> @syncRes.status = 1
            Given -> @spawnSync.withArgs('n', ['io', '0.10']).returns @syncRes
            Then -> ( => @subject.io('0.10') ).should.throw('Unknown error running n ioe0.10')

    describe '.remove', ->
      context 'async', ->
        Given -> @cp.spawn.withArgs('n', ['io', 'rm', '0.10']).returns @child
        Given -> @child.stdout.on.withArgs('data').callsArgWith 1, @output
        Given -> @child.stdout.on.withArgs('close').callsArg 1
        When -> @subject.io.remove '0.10', @cb
        Then -> @cb.calledWith(null, @clean).should.be.true()
        
      context 'sync', ->
        Given -> @spawnSync.withArgs('n', ['io', 'rm', '0.10']).returns @syncRes
        Then -> @subject.io.remove('0.10').should.eql @clean

    describe '.rm', ->
      context 'async', ->
        Given -> @cp.spawn.withArgs('n', ['io', 'rm', '0.10']).returns @child
        Given -> @child.stdout.on.withArgs('data').callsArgWith 1, @output
        Given -> @child.stdout.on.withArgs('close').callsArg 1
        When -> @subject.io.rm '0.10', @cb
        Then -> @cb.calledWith(null, @clean).should.be.true()
        
      context 'sync', ->
        Given -> @spawnSync.withArgs('n', ['io', 'rm', '0.10']).returns @syncRes
        Then -> @subject.io.rm('0.10').should.eql @clean

    describe '.bin', ->
      context 'async', ->
        Given -> @cp.spawn.withArgs('n', ['io', 'bin', '0.10']).returns @child
        Given -> @child.stdout.on.withArgs('data').callsArgWith 1, @output
        Given -> @child.stdout.on.withArgs('close').callsArg 1
        When -> @subject.io.bin '0.10', @cb
        Then -> @cb.calledWith(null, @clean).should.be.true()
        
      context 'sync', ->
        Given -> @spawnSync.withArgs('n', ['io', 'bin', '0.10']).returns @syncRes
        Then -> @subject.io.bin('0.10').should.eql @clean

    describe '.which', ->
      context 'async', ->
        Given -> @cp.spawn.withArgs('n', ['io', 'bin', '0.10']).returns @child
        Given -> @child.stdout.on.withArgs('data').callsArgWith 1, @output
        Given -> @child.stdout.on.withArgs('close').callsArg 1
        When -> @subject.io.which '0.10', @cb
        Then -> @cb.calledWith(null, @clean).should.be.true()
        
      context 'sync', ->
        Given -> @spawnSync.withArgs('n', ['io', 'bin', '0.10']).returns @syncRes
        Then -> @subject.io.which('0.10').should.eql @clean

    describe '.use', ->
      context 'async', ->
        Given -> @cp.spawn.withArgs('n', ['io', 'use', '0.10']).returns @child
        Given -> @child.stdout.on.withArgs('data').callsArgWith 1, @output
        Given -> @child.stdout.on.withArgs('close').callsArg 1
        When -> @subject.io.use '0.10', @cb
        Then -> @cb.calledWith(null, @clean).should.be.true()
        
      context 'sync', ->
        Given -> @spawnSync.withArgs('n', ['io', 'use', '0.10']).returns @syncRes
        Then -> @subject.io.use('0.10').should.eql @clean

    describe '.as', ->
      context 'async', ->
        Given -> @cp.spawn.withArgs('n', ['io', 'use', '0.10']).returns @child
        Given -> @child.stdout.on.withArgs('data').callsArgWith 1, @output
        Given -> @child.stdout.on.withArgs('close').callsArg 1
        When -> @subject.io.as '0.10', @cb
        Then -> @cb.calledWith(null, @clean).should.be.true()
        
      context 'sync', ->
        Given -> @spawnSync.withArgs('n', ['io', 'use', '0.10']).returns @syncRes
        Then -> @subject.io.as('0.10').should.eql @clean

    describe '.list', ->
      context 'async', ->
        Given -> @cp.spawn.withArgs('n', ['io', 'ls']).returns @child
        Given -> @child.stdout.on.withArgs('data').callsArgWith 1, @versions
        Given -> @child.stdout.on.withArgs('close').callsArg 1
        When -> @subject.io.list @cb
        Then -> @cb.calledWith(null, @versionsArr).should.be.true()
        
      context 'sync', ->
        Given -> @syncRes.stdout = @versions
        Given -> @spawnSync.withArgs('n', ['io', 'ls']).returns @syncRes
        Then -> @subject.io.ls().should.eql @versionsArr

    describe '.ls', ->
      context 'async', ->
        Given -> @cp.spawn.withArgs('n', ['io', 'ls']).returns @child
        Given -> @child.stdout.on.withArgs('data').callsArgWith 1, @versions
        Given -> @child.stdout.on.withArgs('close').callsArg 1
        When -> @subject.io.ls @cb
        Then -> @cb.calledWith(null, @versionsArr).should.be.true()
        
      context 'sync', ->
        Given -> @syncRes.stdout = @versions
        Given -> @spawnSync.withArgs('n', ['io', 'ls']).returns @syncRes
        Then -> @subject.io.ls().should.eql @versionsArr
