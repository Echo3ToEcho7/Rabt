fs = require 'fs'
c = require './lib'

c.compiler.compileFile './test/content/build/foo.js', './test/content/src/foo.iced'
c.compiler.compileFile './test/content/build/bar.js', './test/content/src/bar.iced'
c.compiler.compileFile './test/content/build/queries/main.js', './test/content/src/queries/main.js'

b = new c.builder.Builder

content = b.build('./test/content/build/bar.js')
fs.writeFileSync './test/content/test.comp.js', content

l = new c.linker.Linker
j = fs.readFileSync './test/content/app.jade'

fs.writeFileSync './test/content/out.html', (l.link j, content)