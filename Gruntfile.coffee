module.exports = (grunt) ->

  # Utilities
  # =========
  #path = require 'path'

  # Package
  # =======
  pkg = require './package.json'

  # Modules
  # =======
  # TODO: Remove this as soon as uRequire releases 0.3 which will able to
  #  do this for us in the right order magically.
  modules = [
#    'temp//application.js'
#    'temp//mediator.js'
#    'temp//dispatcher.js'
#    'temp//composer.js'
#    'temp//controllers/controller.js'
#    'temp//models/collection.js'
#    'temp//models/model.js'
#    'temp//views/layout.js'
#    'temp//views/view.js'
#    'temp//views/collection_view.js'
#    'temp//lib/route.js'
#    'temp//lib/router.js'
#    'temp//lib/delayer.js'
#    'temp//lib/event_broker.js'
#    'temp//lib/support.js'
#    'temp//lib/composition.js'
#    'temp//lib/sync_machine.js'
#    'temp//lib/utils.js'
#    'temp//lib/helpers.js'
#    'temp/.js'
  ]

  # Configuration
  # =============
  grunt.initConfig

    # Package
    # -------
    pkg: pkg

    # Clean
    # -----
    clean:
      build: 'build'
      temp: 'temp'
      components: 'components'
      test: ['test/temp*', 'test/coverage']

    # Compilation
    # -----------
    coffee:
      compile:
        files: [
          expand: true
          dest: 'temp/'
          cwd: 'src'
          src: '**/*.coffee'
          ext: '.js'
        ]

      test:
        files: [
          expand: true
          dest: 'test/temp/'
          cwd: 'test/spec'
          src: '**/*.coffee'
          ext: '.js'
        ]

      options:
        bare: true

    # Module naming
    # -------------
    # TODO: Remove this when uRequire hits 0.3
    copy:
      commonjs:
        files: [
          expand: true
          dest: 'temp/'
          cwd: 'temp'
          src: '**/*.js'
        ]

        options:
          processContent: (content, path) ->
            name = ///temp/(.*)\.js///.exec(path)[1]
            """
            require.define({'#{name}': function(exports, require, module) {
            #{content}
            }});
            """

      amd:
        files: [
          expand: true
          dest: 'temp/'
          cwd: 'temp'
          src: '**/*.js'
        ]

        options:
          processContent: (content, path) ->
            name = ///temp/(.*)\.js///.exec(path)[1]
            content.replace ///define\(///, "define('#{name}',"

      test:
        files: [
          expand: true
          dest: 'test/temp/'
          cwd: 'temp'
          src: '**/*.js'
        ]

      beforeInstrument:
        files: [
          expand: true
          dest: 'test/temp-original/'
          cwd: 'test/temp'
          src: '**/*.js'
        ]

      afterInstrument:
        files: [
          expand: true
          dest: 'test/temp/'
          cwd: 'test/temp-original'
          src: '**/*.js'
        ]

    # Module concatenation
    # --------------------
    # TODO: Remove this when uRequire hits 0.3
    concat:
      options:
        separator: ';'
        banner: '''
        /*!
         * Goatee <%= pkg.version %>
         *
         * Goatee may be freely distributed under the BSD license.
         * For all details and documentation:
         * http://goateejs.org
         */


        '''

      amd:
        files: [
          dest: 'build/amd/<%= pkg.name %>.js'
          src: modules
        ]

      commonjs:
        files: [
          dest: 'build/commonjs/<%= pkg.name %>.js'
          src: modules
        ]

      brunch:
        files: [
          dest: 'build/brunch/<%= pkg.name %>.js'
          src: modules
        ]

        options:
          banner: '''
          /*!
           * Goatee <%= pkg.version %>
           *
           * Goatee may be freely distributed under the BSD license.
           * For all details and documentation:
           * http://goateejs.org
           */

          // Dirty hack for require-ing backbone and underscore.
          (function() {
            var deps = {
              backbone: window.Backbone, underscore: window._
            }, fn = function(name) {
              var definition = {};
              definition[name] = function(exports, require, module) {
                module.exports = deps[name];
              };

              try {
                require(item);
              } catch(e) {
                require.define(definition);
              }
            };
            for (var name in deps) {
              fn(name);
            }
          })();


          '''

    # Lint
    # ----
    coffeelint:
      source: 'src/**/*.coffee'
      grunt: 'Gruntfile.coffee'

    # Instrumentation
    # ---------------
    instrument:
      files: [
        'test/temp/goatee.js'
        'test/temp/goatee/**/*.js'
      ]

      options:
        basePath: '.'

    storeCoverage:
      options:
        dir : '.'
        json : 'coverage.json'
        coverageVar : '__coverage__'

    makeReport:
      src: 'coverage.json'
      options:
        type: 'html'
        dir: 'test/coverage'

    # Test runner
    # -----------
    mocha:
      index:
        src: ['test/index.html']
        # options:
        #   grep: 'autoAttach'
        #   mocha:
        #     grep: 'autoAttach'

    # Minify
    # ------
    uglify:
      options:
        mangle: false

      amd:
        files:
          'build/amd/goatee.min.js': 'build/amd/goatee.js'

      commonjs:
        files:
          'build/commonjs/goatee.min.js': 'build/commonjs/goatee.js'

      brunch:
        files:
          'build/brunch/goatee.min.js': 'build/brunch/goatee.js'

    # Compression
    # -----------
    compress:
      amd:
        files: [
          src: 'build/amd/goatee.min.js'
          dest: 'build/amd/goatee.min.js.gz'
        ]

      commonjs:
        files: [
          src: 'build/commonjs/goatee.min.js'
          dest: 'build/commonjs/goatee.min.js.gz'
        ]

      brunch:
        files: [
          src: 'build/brunch/goatee.min.js'
          dest: 'build/brunch/goatee.min.js.gz'
        ]

    # Watching for changes
    # --------------------
    watch:
      coffee:
        files: ['src/**/*.coffee']
        tasks: [
          'coffee:compile'
          'copy:amd'
          'copy:test'
          'mocha'
        ]

      test:
        files: ['test/spec/*.coffee'],
        tasks: [
          'coffee:test'
          'mocha'
        ]

  # Events
  # ======
  grunt.event.on 'mocha.coverage', (coverage) ->
    # This is needed so the coverage reporter will find the coverage variable.
    global.__coverage__ = coverage

  # Dependencies
  # ============
  for name of pkg.devDependencies when name.substring(0, 6) is 'grunt-'
    grunt.loadNpmTasks name

  # Tasks
  # =====

  # Prepare
  # -------
  grunt.registerTask 'prepare', [
    'clean'
    'clean:components'
  ]

  # Build
  # -----
  grunt.registerTask 'build:commonjs', [
    'coffee:compile'
    'copy:commonjs'
    'concat:commonjs'
  ]

  grunt.registerTask 'build:amd', [
    'coffee:compile'
    'copy:amd'
    'concat:amd'
  ]

  grunt.registerTask 'build:brunch', [
    'coffee:compile'
    'copy:commonjs'
    'concat:brunch'
  ]

  grunt.registerTask 'build:minified', [
    'uglify:commonjs'
    'compress:commonjs'
    'uglify:amd'
    'compress:amd'
    'uglify:brunch'
    'compress:brunch'
  ]

  grunt.registerTask 'build:all', [
    'build:amd'
    'build:commonjs'
    'build:brunch'
    'build:minified'
  ]

  grunt.registerTask 'build', [
    'build:amd'
    'build:commonjs'
    'build:brunch'
  ]

  # Lint
  # ----
  grunt.registerTask 'lint', 'coffeelint'

  # Test
  # ----
  grunt.registerTask 'test', [
    'coffee:compile'
    'copy:amd'
    'copy:test'
    'coffee:test'
    'mocha'
  ]

  # Coverage
  # --------
  grunt.registerTask 'cover', [
    'coffee:compile'
    'copy:amd'
    'copy:test'
    'coffee:test'
    'copy:beforeInstrument'
    'instrument'
    'mocha'
    'storeCoverage'
    'copy:afterInstrument'
    'makeReport'
  ]

  # Test Watcher
  # ------------
  grunt.registerTask 'test-watch', [
    'test'
    'watch'
  ]

  # Publish Documentation
  # ---------------------
  grunt.registerTask 'docs:publish', 'Publish docs to gh-pages branch.', ->
    path = require('path')
    temp = require('temp')

    continuation = this.async()
    tmpDirPath = temp.path()

    grunt.file.recurse path.join('docs'), (abspath, rootdir, subdir, filename) \
      ->
      parent = if subdir then path.join(tmpDirPath, subdir) else tmpDirPath
      grunt.file.mkdir parent
      grunt.file.copy abspath, path.join(parent, filename)
    gitArgs = [
      ['init', '.']
      ['add', '.'],
      ['commit', '-m', "Add docs from #{(new Date).toISOString()}"],
      ['remote', 'add', 'origin', 'git@github.com:sjorek/goateejs.git'],
      ['push', 'origin', 'master:refs/heads/gh-pages', '--force']
    ]
    gitRunner = (args, next) ->
      grunt.util.spawn {
        cmd: "git", args: args, opts: {cwd: tmpDirPath}
      }, (error, result, code) -> next(error)
    grunt.util.async.forEachSeries gitArgs, gitRunner, ->
      grunt.file.delete tmpDirPath, force: true
      grunt.log.writeln "Published docs to gh-pages."
      continuation()

  # Default
  # -------
  grunt.registerTask 'default', [
    'lint'
    'clean'
    'build'
    'test'
  ]