describe 'n-wrap', ->
  Given -> @subject = require '../../lib/n-wrap'

  xcontext 'sync', ->
    Then ->
      versions = @subject.ls()
      
