import chai from 'chai'

import logger from 'utils/logger'
import { select, div } from 'utils/selection'
import { animate, morph } from 'utils/animate'
import { EventEmitter } from 'utils/event-emitter'
import { ease } from 'utils/transition'

import installFakeTimers from 'test/utils/fake-time'

export default () ->
  describe 'animate', ->
    # now = -> Date.now()
    #
    # class Delay extends EventEmitter
    #   constructor: (duration) ->
    #     super()
    #     @timeout = setTimeout((=> @emit('end')), duration)
    #
    #   cancel: => clearTimeout(@timeout)
    #
    # morph.register 'delay', (node, duration=100) ->
    #   new Delay(duration)
    #
    # class FakeNode
    #   constructor: ->
    #     @styles = {}
    #     @attrs = {}
    #     self = this
    #     @style = {
    #       setProperty: (prop, value) ->
    #         self.styles[prop] = value
    #     }
    #
    #     @setAttribute = (prop, value) ->
    #       self.attrs[prop] = value
    #
    #     @getAttribute = (prop) -> self.attrs[prop]
    #
    # savedGetComputedStyle = undefined
    # clock = undefined
    #
    # beforeEach ->
    #   savedGetComputedStyle = window.getComputedStyle
    #   window.getComputedStyle = (node, thing) ->
    #     {
    #       getPropertyValue: (prop) -> node.styles[prop]
    #     }
    #   clock = installFakeTimers()
    #
    #
    # afterEach ->
    #   window.getComputedStyle = savedGetComputedStyle
    #   clock.restore()
    #
    # describe 'animate', ->
    #
    #   it 'Selection::animate should return an animation', ->
    #     node = div().node()
    #     easeFunc = ->
    #     fromSelection = select(node).animate(easeFunc)
    #     normal = animate(node, easeFunc)
    #     fromSelection.node.should.equal(normal.node)
    #     fromSelection.ease.should.equal(normal.ease)
    #
    #   describe 'style', ->
    #     it 'should emit end at the end of an animation', ->
    #       end = false
    #       animate(new FakeNode)
    #         .style('height', '100%', 10)
    #         .on 'end', -> end = true
    #
    #       clock.tick(10)
    #       end.should.equal(true)
    #
    #     it 'the easing function passed in should be used', ->
    #       easeFunc = (d) -> Math.sqrt(Math.abs(d))
    #       anim = animate(new FakeNode, easeFunc)
    #       anim.ease.should.equal(easeFunc)
    #
    #     it 'should emit end at the end of an animation with multiple styles', ->
    #       end = false
    #       animate(new FakeNode)
    #         .style('height', '100%', 10)
    #         .style('width', '100%', 10)
    #         .on 'end', -> end = true
    #
    #       clock.tick(10)
    #       end.should.equal(true)
    #
    #     it 'should take roughly the amount of time requested', ->
    #       start = now()
    #       time = undefined
    #       animate(new FakeNode)
    #         .style('height', '100%', 100)
    #         .style('width', '100%', 50)
    #         .on 'end', ->
    #           time = now() - start
    #
    #       clock.tick(100)
    #
    #       time.should.equal(100)
    #
    #     it 'should take roughly the amount of time requested (using default)', ->
    #       start = now()
    #       time = undefined
    #       animate(new FakeNode)
    #         .style('height', '100%')
    #         .style('width', '100%', 50)
    #         .on 'end', ->
    #           time = now() - start
    #
    #       clock.tick(200)
    #       time.should.equal(200)
    #
    #     it 'if you dont supply a node, then the end event should be emitted straight away', ->
    #       end = false
    #       animate()
    #         .on 'end', -> end = true
    #         .style('height', '100%', 100)
    #         .style('width', '100%', 50)
    #
    #       end.should.equal(true)
    #
    #     it 'should only emit end once', ->
    #       count = 0
    #       animate()
    #         .on('end', -> count++)
    #         .style('height', '100%', 100)
    #         .style('width', '100%', 50)
    #
    #
    #       count.should.equal(1)
    #
    #     it 'should end on the correct values', ->
    #       node = new FakeNode
    #       animate(node)
    #         .style('height', '100%', 100)
    #         .style('width', '100%', 50)
    #
    #       clock.tick(100)
    #       node.styles['height'].should.equal('100%')
    #       node.styles['width'].should.equal('100%')
    #
    #     it 'should end on the correct values', ->
    #
    #       end = false
    #       node = new FakeNode
    #       node.styles['width'] = '0%'
    #       node.styles['height'] = '50%'
    #
    #       animate(node)
    #         .style('height', '100%', 100)
    #         .style('width', '100%', 50)
    #
    #       clock.tick(100)
    #       node.styles['height'].should.equal('100%')
    #       node.styles['width'].should.equal('100%')
    #
    #     it 'should interpolate to the correct values', ->
    #
    #       end = false
    #       node = new FakeNode
    #       node.styles['width'] = '0%'
    #       node.styles['height'] = '50%'
    #
    #       animate(node)
    #         .style('width', '100%', 100)
    #         .style('height', '100%', 100)
    #
    #       clock.tick(25)
    #       node.styles['width'].should.equal('25%')
    #       node.styles['height'].should.equal('62.5%')
    #
    #       clock.tick(25)
    #       node.styles['width'].should.equal('50%')
    #       node.styles['height'].should.equal('75%')
    #
    #       clock.tick(50)
    #       node.styles['width'].should.equal('100%')
    #       node.styles['height'].should.equal('100%')
    #
    #     it 'changing the easing function should affect the values', ->
    #
    #       end = false
    #       node = new FakeNode
    #       node.styles['width'] = '0%'
    #       node.styles['height'] = '50%'
    #
    #       animate(node, ease.cubic)
    #         .style('width', '100%', 100)
    #         .style('height', '100%', 100)
    #
    #       clock.tick(25)
    #       node.styles['width'].should.equal('1.5625%')
    #
    #       clock.tick(25)
    #       node.styles['width'].should.equal('12.5%')
    #       node.styles['height'].should.equal('56.25%')
    #
    #       clock.tick(50)
    #       node.styles['width'].should.equal('100%')
    #       node.styles['height'].should.equal('100%')
    #
    #     it 'changing the easing function should affect the values', ->
    #
    #       end = false
    #       node = new FakeNode
    #       node.styles['width'] = '0%'
    #       node.styles['height'] = '50%'
    #
    #       animate(node, ease.quad)
    #         .style('width', '100%', 100)
    #         .style('height', '100%', 100)
    #
    #       clock.tick(25)
    #       node.styles['width'].should.equal('6.25%')
    #
    #       clock.tick(25)
    #       node.styles['width'].should.equal('25%')
    #       node.styles['height'].should.equal('62.5%')
    #
    #       clock.tick(50)
    #       node.styles['width'].should.equal('100%')
    #       node.styles['height'].should.equal('100%')
    #
    #     it 'should interpolate the correct values', ->
    #
    #       end = false
    #       node = new FakeNode
    #
    #       animate(node)
    #         .style('width', '0%', '100%', 100)
    #         .style('height', '50%', '100%', 100)
    #
    #       clock.tick(25)
    #       node.styles['width'].should.equal('25%')
    #       node.styles['height'].should.equal('62.5%')
    #
    #       clock.tick(25)
    #       node.styles['width'].should.equal('50%')
    #       node.styles['height'].should.equal('75%')
    #
    #       clock.tick(50)
    #       node.styles['width'].should.equal('100%')
    #       node.styles['height'].should.equal('100%')
    #
    #     it 'should interpolate the correct values', ->
    #
    #       end = false
    #       node = new FakeNode
    #
    #       animate(node)
    #         .style('width', '0%', '100%', undefined)
    #         .style('height', '50%', '100%', undefined)
    #
    #       clock.tick(50)
    #       node.styles['width'].should.equal('25%')
    #       node.styles['height'].should.equal('62.5%')
    #
    #       clock.tick(50)
    #       node.styles['width'].should.equal('50%')
    #       node.styles['height'].should.equal('75%')
    #
    #       clock.tick(100)
    #       node.styles['width'].should.equal('100%')
    #       node.styles['height'].should.equal('100%')
    #
    #     it 'cancel should work for range animations', ->
    #
    #       end = false
    #       node = new FakeNode
    #
    #       anim = animate(node)
    #         .style('width', '0%', '100%', undefined)
    #         .style('height', '50%', '100%', undefined)
    #
    #       clock.tick(50)
    #       node.styles['width'].should.equal('25%')
    #       node.styles['height'].should.equal('62.5%')
    #
    #       anim.cancel()
    #
    #       clock.tick(50)
    #       node.styles['width'].should.equal('25%')
    #       node.styles['height'].should.equal('62.5%')
    #
    #       clock.tick(100)
    #       node.styles['width'].should.equal('25%')
    #       node.styles['height'].should.equal('62.5%')
    #
    #     it 'cancel should work for range animations', ->
    #
    #       end = false
    #       node = new FakeNode
    #       node.styles['width'] = '0%'
    #       node.styles['height'] = '50%'
    #
    #       anim = animate(node)
    #         .style('width', '100%')
    #         .style('height', '100%')
    #
    #       clock.tick(50)
    #       node.styles['width'].should.equal('25%')
    #       node.styles['height'].should.equal('62.5%')
    #
    #       anim.cancel()
    #
    #       clock.tick(50)
    #       node.styles['width'].should.equal('25%')
    #       node.styles['height'].should.equal('62.5%')
    #
    #       clock.tick(100)
    #       node.styles['width'].should.equal('25%')
    #       node.styles['height'].should.equal('62.5%')
    #
    #   describe 'attr', ->
    #     it 'should emit end at the end of an animation', ->
    #       end = false
    #       animate(new FakeNode)
    #         .attr('height', '100%', 10)
    #         .on 'end', -> end = true
    #
    #       clock.tick(10)
    #       end.should.equal(true)
    #
    #     it 'the easing function passed in should be used', ->
    #       easeFunc = (d) -> Math.sqrt(Math.abs(d))
    #       anim = animate(new FakeNode, easeFunc)
    #       anim.ease.should.equal(easeFunc)
    #
    #     it 'should emit end at the end of an animation with multiple attrs', ->
    #       end = false
    #       animate(new FakeNode)
    #         .attr('height', '100%', 10)
    #         .attr('width', '100%', 10)
    #         .on 'end', -> end = true
    #
    #       clock.tick(10)
    #       end.should.equal(true)
    #
    #     it 'should take roughly the amount of time requested', ->
    #       start = now()
    #       time = undefined
    #       animate(new FakeNode)
    #         .attr('height', '100%', 100)
    #         .attr('width', '100%', 50)
    #         .on 'end', ->
    #           time = now() - start
    #
    #       clock.tick(100)
    #
    #       time.should.equal(100)
    #
    #     it 'should take roughly the amount of time requested (using default)', ->
    #       start = now()
    #       time = undefined
    #       animate(new FakeNode)
    #         .attr('height', '100%')
    #         .attr('width', '100%', 50)
    #         .on 'end', ->
    #           time = now() - start
    #
    #       clock.tick(200)
    #       time.should.equal(200)
    #
    #     it 'if you dont supply a node, then the end event should be emitted straight away', ->
    #       end = false
    #       animate()
    #         .on 'end', -> end = true
    #         .attr('height', '100%', 100)
    #         .attr('width', '100%', 50)
    #
    #       end.should.equal(true)
    #
    #     it 'should only emit end once', ->
    #       count = 0
    #       animate()
    #         .on 'end', -> count++
    #         .attr('height', '100%', 100)
    #         .attr('width', '100%', 50)
    #
    #
    #       count.should.equal(1)
    #
    #     it 'should end on the correct values', ->
    #       node = new FakeNode
    #       animate(node)
    #         .attr('height', '100%', 100)
    #         .attr('width', '100%', 50)
    #
    #       clock.tick(100)
    #       node.attrs['height'].should.equal('100%')
    #       node.attrs['width'].should.equal('100%')
    #
    #     it 'should end on the correct values', ->
    #
    #       end = false
    #       node = new FakeNode
    #       node.attrs['width'] = '0%'
    #       node.attrs['height'] = '50%'
    #
    #       animate(node)
    #         .attr('height', '100%', 100)
    #         .attr('width', '100%', 50)
    #
    #       clock.tick(100)
    #       node.attrs['height'].should.equal('100%')
    #       node.attrs['width'].should.equal('100%')
    #
    #     it 'should interpolate to the correct values', ->
    #
    #       end = false
    #       node = new FakeNode
    #       node.attrs['width'] = '0%'
    #       node.attrs['height'] = '50%'
    #
    #       animate(node)
    #         .attr('width', '100%', 100)
    #         .attr('height', '100%', 100)
    #
    #       clock.tick(25)
    #       node.attrs['width'].should.equal('25%')
    #       node.attrs['height'].should.equal('62.5%')
    #
    #       clock.tick(25)
    #       node.attrs['width'].should.equal('50%')
    #       node.attrs['height'].should.equal('75%')
    #
    #       clock.tick(50)
    #       node.attrs['width'].should.equal('100%')
    #       node.attrs['height'].should.equal('100%')
    #
    #     it 'changing the easing function should affect the values', ->
    #
    #       end = false
    #       node = new FakeNode
    #       node.attrs['width'] = '0%'
    #       node.attrs['height'] = '50%'
    #
    #       animate(node, ease.cubic)
    #         .attr('width', '100%', 100)
    #         .attr('height', '100%', 100)
    #
    #       clock.tick(25)
    #       node.attrs['width'].should.equal('1.5625%')
    #
    #       clock.tick(25)
    #       node.attrs['width'].should.equal('12.5%')
    #       node.attrs['height'].should.equal('56.25%')
    #
    #       clock.tick(50)
    #       node.attrs['width'].should.equal('100%')
    #       node.attrs['height'].should.equal('100%')
    #
    #     it 'changing the easing function should affect the values', ->
    #
    #       end = false
    #       node = new FakeNode
    #       node.attrs['width'] = '0%'
    #       node.attrs['height'] = '50%'
    #
    #       animate(node, ease.quad)
    #         .attr('width', '100%', 100)
    #         .attr('height', '100%', 100)
    #
    #       clock.tick(25)
    #       node.attrs['width'].should.equal('6.25%')
    #
    #       clock.tick(25)
    #       node.attrs['width'].should.equal('25%')
    #       node.attrs['height'].should.equal('62.5%')
    #
    #       clock.tick(50)
    #       node.attrs['width'].should.equal('100%')
    #       node.attrs['height'].should.equal('100%')
    #
    #     it 'should interpolate the correct values', ->
    #
    #       end = false
    #       node = new FakeNode
    #
    #       animate(node)
    #         .attr('width', '0%', '100%', 100)
    #         .attr('height', '50%', '100%', 100)
    #
    #       clock.tick(25)
    #       node.attrs['width'].should.equal('25%')
    #       node.attrs['height'].should.equal('62.5%')
    #
    #       clock.tick(25)
    #       node.attrs['width'].should.equal('50%')
    #       node.attrs['height'].should.equal('75%')
    #
    #       clock.tick(50)
    #       node.attrs['width'].should.equal('100%')
    #       node.attrs['height'].should.equal('100%')
    #
    #     it 'should interpolate the correct values', ->
    #
    #       end = false
    #       node = new FakeNode
    #
    #       animate(node)
    #         .attr('width', '0%', '100%', undefined)
    #         .attr('height', '50%', '100%', undefined)
    #
    #       clock.tick(50)
    #       node.attrs['width'].should.equal('25%')
    #       node.attrs['height'].should.equal('62.5%')
    #
    #       clock.tick(50)
    #       node.attrs['width'].should.equal('50%')
    #       node.attrs['height'].should.equal('75%')
    #
    #       clock.tick(100)
    #       node.attrs['width'].should.equal('100%')
    #       node.attrs['height'].should.equal('100%')
    #
    #     it 'cancel should work for range animations', ->
    #
    #       end = false
    #       node = new FakeNode
    #
    #       anim = animate(node)
    #         .attr('width', '0%', '100%', undefined)
    #         .attr('height', '50%', '100%', undefined)
    #
    #       clock.tick(50)
    #       node.attrs['width'].should.equal('25%')
    #       node.attrs['height'].should.equal('62.5%')
    #
    #       anim.cancel()
    #
    #       clock.tick(50)
    #       node.attrs['width'].should.equal('25%')
    #       node.attrs['height'].should.equal('62.5%')
    #
    #       clock.tick(100)
    #       node.attrs['width'].should.equal('25%')
    #       node.attrs['height'].should.equal('62.5%')
    #
    #     it 'cancel should work for range animations', ->
    #
    #       end = false
    #       node = new FakeNode
    #       node.attrs['width'] = '0%'
    #       node.attrs['height'] = '50%'
    #
    #       anim = animate(node)
    #         .attr('width', '100%')
    #         .attr('height', '100%')
    #
    #       clock.tick(50)
    #       node.attrs['width'].should.equal('25%')
    #       node.attrs['height'].should.equal('62.5%')
    #
    #       anim.cancel()
    #
    #       clock.tick(50)
    #       node.attrs['width'].should.equal('25%')
    #       node.attrs['height'].should.equal('62.5%')
    #
    #       clock.tick(100)
    #       node.attrs['width'].should.equal('25%')
    #       node.attrs['height'].should.equal('62.5%')
    #
    #
    # describe 'morph', ->
    #
    #   it 'Selection::morph should return a morph', ->
    #     node = div().node()
    #     fromSelection = select(node).morph()
    #     normal = morph(node)
    #     fromSelection.node.should.equal(normal.node)
    #
    #   it 'should proceed straight away for no argument functions that are not event emitters', ->
    #     called1 = false
    #     called2 = false
    #     morph()
    #       .then -> called1 = true
    #       .then -> called2 = true
    #       .go()
    #
    #     called1.should.equal(true)
    #     called2.should.equal(true)
    #
    #   it 'should wait until async functions finish before continuing', ->
    #     called = false
    #
    #     morph()
    #       .then (done) -> setTimeout(done, 100)
    #       .then -> called = true
    #       .go()
    #
    #     called.should.equal(false)
    #     clock.tick(25)
    #     called.should.equal(false)
    #     clock.tick(100)
    #     called.should.equal(true)
    #
    #   it 'should wait until event emitters emit end finish before continuing', ->
    #     called = false
    #
    #     morph()
    #       .then (done) ->
    #         ee = new EventEmitter
    #         setTimeout((-> ee.emit('end')), 100)
    #         ee
    #       .then -> called = true
    #       .go()
    #
    #     called.should.equal(false)
    #     clock.tick(25)
    #     called.should.equal(false)
    #     clock.tick(100)
    #     called.should.equal(true)
    #
    #   it 'should cancel ongoing morphs correctly', ->
    #     called1 = false
    #     called2 = false
    #
    #     node = new FakeNode
    #
    #     morph(node)
    #       .then (done) -> setTimeout(done, 100)
    #       .then -> called1 = true
    #       .go()
    #
    #     clock.tick(25)
    #
    #     morph(node)
    #       .then (done) -> setTimeout(done, 100)
    #       .then -> called2 = true
    #       .go(true)
    #
    #     clock.tick(150)
    #
    #     called1.should.equal(false)
    #     called2.should.equal(true)
    #
    #   it 'should do nothing when you cancel an ongoing morph when a node isnt given', ->
    #     called1 = false
    #     called2 = false
    #
    #     morph()
    #       .then (done) -> setTimeout(done, 100)
    #       .then -> called1 = true
    #       .go()
    #
    #     clock.tick(25)
    #
    #     morph()
    #       .then (done) -> setTimeout(done, 100)
    #       .then -> called2 = true
    #       .go(true)
    #
    #     clock.tick(150)
    #
    #     called1.should.equal(true)
    #     called2.should.equal(true)
    #
    #   it 'should be fine with cancelling morphs on a node that hasnt got any', ->
    #     called = false
    #
    #     morph(new FakeNode)
    #       .then (done) ->
    #         setTimeout(done, 100)
    #       .then -> called = true
    #       .go(true)
    #
    #     clock.tick(150)
    #
    #     called.should.equal(true)
    #
    #   it 'should be fine with cancelling morphs on a node that hasnt got any (due to them all expiring)', ->
    #     called = false
    #     node = new FakeNode
    #
    #     node.__hx__ = {}
    #
    #     morph(node)
    #       .then (done) -> setTimeout(done, 100)
    #       .then -> called = true
    #       .go(true)
    #
    #     clock.tick(150)
    #
    #     called.should.equal(true)
    #
    #   it 'should ignore things that have already been cancelled', ->
    #     called = false
    #     node = new FakeNode
    #
    #     node.__hx__ = {
    #       morphs: [
    #         { cancelled: true, cancel: -> called = true }
    #       ]
    #     }
    #
    #     morph(node)
    #       .then (done) -> setTimeout(done, 100)
    #       .go(true)
    #
    #     called.should.equal(false)
    #
    #   it 'cancelling a morph twice should be fine', ->
    #     node = new FakeNode
    #
    #     morphInstance = morph(node)
    #       .then (done) -> setTimeout(done, 100)
    #       .go(true)
    #
    #     morphInstance.cancel()
    #
    #     chai.expect(-> morphInstance.cancel()).to.not.throw()
    #
    #     return
    #
    #   it 'when cancelling, the cancellers should be called', ->
    #     node = new FakeNode
    #
    #     cancelled1 = false
    #     cancelled2 = false
    #
    #     morphInstance = morph(node)
    #       .then (done) -> {cancel: -> cancelled1 = true}
    #       .and (done) -> {cancel: -> cancelled2 = true}
    #       .go()
    #
    #     morphInstance.cancel()
    #
    #     cancelled1.should.equal(true)
    #     cancelled2.should.equal(true)
    #
    #   it 'shouldnt fall over on cancel properties that isnt a function', ->
    #     node = new FakeNode
    #
    #     cancelled1 = false
    #     cancelled2 = false
    #
    #     morphInstance = morph(node)
    #       .then (done) -> {cancel: 'not-a-function'}
    #       .and (done) -> {cancel: -> cancelled1 = true}
    #       .and (done) -> {cancel: -> cancelled2 = true}
    #       .go()
    #
    #     chai.expect(-> morphInstance.cancel()).to.not.throw()
    #
    #   it 'should ignore things that have already finished', ->
    #     called = false
    #     node = new FakeNode
    #
    #     node.__hx__ = {
    #       morphs: [
    #         { finished: true, cancel: -> called = true }
    #       ]
    #     }
    #
    #     morph(node).go(true)
    #
    #     called.should.equal(false)
    #
    #   it 'should filter out cancelled morphs when a new one is started', ->
    #     called = false
    #     node = new FakeNode
    #
    #     original = [
    #       { cancel: -> called = true }
    #       { finised: true, cancel: -> called = true }
    #       { cancelled: true, cancel: -> called = true }
    #     ]
    #
    #     node.__hx__ = {
    #       morphs: original.slice()
    #     }
    #
    #     morph(node).go(false)
    #
    #     node.__hx__.morphs.should.contain(original[0])
    #
    #   it 'things with a cancel method should be put onto the cancellers array', ->
    #     node = new FakeNode
    #
    #     obj = { cancel: -> }
    #
    #     morphInstance = morph(node)
    #       .then (done) -> obj
    #       .and (done) -> obj
    #       .and (done) -> obj
    #       .go()
    #
    #     morphInstance.cancelers.should.eql([obj, obj, obj])
    #
    #
    #   it 'should wait until all async things have finished before emitting end', ->
    #     called1 = false
    #     called2 = false
    #     called3 = false
    #     end = false
    #
    #     morph()
    #       .then (done) ->
    #         finish = ->
    #           called1 = true
    #           done()
    #         setTimeout(finish, 100)
    #       .and (done) ->
    #         finish = ->
    #           called2 = true
    #           done()
    #         setTimeout(finish, 200)
    #       .and (done) ->
    #         finish = ->
    #           called3 = true
    #           done()
    #         setTimeout(finish, 300)
    #       .go()
    #       .on 'end', -> end = true
    #
    #     clock.tick(101)
    #     called1.should.equal(true)
    #     called2.should.equal(false)
    #     called3.should.equal(false)
    #     end.should.equal(false)
    #
    #     clock.tick(100)
    #     called1.should.equal(true)
    #     called2.should.equal(true)
    #     called3.should.equal(false)
    #     end.should.equal(false)
    #
    #     clock.tick(100)
    #     called1.should.equal(true)
    #     called2.should.equal(true)
    #     called3.should.equal(true)
    #     end.should.equal(true)
    #
    #   it 'with should do the same as then', ->
    #     called1 = false
    #     called2 = false
    #     called3 = false
    #     end = false
    #
    #     morph()
    #       .with (done) ->
    #         finish = ->
    #           called1 = true
    #           done()
    #         setTimeout(finish, 100)
    #       .and (done) ->
    #         finish = ->
    #           called2 = true
    #           done()
    #         setTimeout(finish, 200)
    #       .and (done) ->
    #         finish = ->
    #           called3 = true
    #           done()
    #         setTimeout(finish, 300)
    #       .on 'end', -> end = true
    #       .go()
    #
    #     clock.tick(101)
    #     called1.should.equal(true)
    #     called2.should.equal(false)
    #     called3.should.equal(false)
    #     end.should.equal(false)
    #
    #     clock.tick(100)
    #     called1.should.equal(true)
    #     called2.should.equal(true)
    #     called3.should.equal(false)
    #     end.should.equal(false)
    #
    #     clock.tick(100)
    #     called1.should.equal(true)
    #     called2.should.equal(true)
    #     called3.should.equal(true)
    #     end.should.equal(true)
    #
    #   it 'named morphs should work', ->
    #     end = false
    #
    #     class Delay extends EventEmitter
    #       constructor: (duration) ->
    #         super()
    #         @timeout = setTimeout((=> @emit('end')), duration)
    #
    #       cancel: => clearTimeout(@timeout)
    #
    #     morph.register 'delay', (node, duration=100) ->
    #       new Delay(duration)
    #
    #     morph.register 'delay2', (node, duration=100) ->
    #       new Delay(duration)
    #
    #     node = new FakeNode
    #
    #     morph(node)
    #       .with('delay', 500).and('delay2', 100)
    #       .on 'end', -> end = true
    #       .go()
    #
    #     clock.tick(101)
    #     end.should.equal(false)
    #
    #     clock.tick(400)
    #     end.should.equal(true)
    #
    #   it 'named morphs should do nothing when you have no node', ->
    #     end = false
    #
    #     class Delay extends EventEmitter
    #       constructor: (duration) ->
    #         super()
    #         @timeout = setTimeout((=> @emit('end')), duration)
    #
    #       cancel: => clearTimeout(@timeout)
    #
    #     morph.register 'delay', (node, duration=100) ->
    #       new Delay(duration)
    #
    #     morph.register 'delay2', (node, duration=100) ->
    #       new Delay(duration)
    #
    #     morph()
    #       .with('delay', 500).and('delay2', 100)
    #       .on 'end', -> end = true
    #       .go()
    #
    #     clock.tick(101)
    #     end.should.equal(true)
    #
    #     clock.tick(400)
    #     end.should.equal(true)
    #
    #   it 'a warning should be thrown when a named morph is used that doesnt exist', ->
    #     originalWarn = logger.warn
    #     logger.warn = chai.spy()
    #
    #     morph(new FakeNode)
    #       .with('delay5', 500)
    #       .go()
    #
    #     logger.warn.should.have.been.called.once
    #     logger.warn = originalWarn
    #
    #   it 'andStyle should affect an elements styles', ->
    #     node = new FakeNode
    #
    #     node.styles['height'] = '0'
    #
    #     morph(node)
    #       .andStyle('height', '100')
    #       .go()
    #
    #     node.styles['height'].should.equal('0')
    #     clock.tick(100)
    #     node.styles['height'].should.equal('50')
    #     clock.tick(100)
    #     node.styles['height'].should.equal('100')
    #
    #   it 'andStyle should affect an elements styles (with custom duration)', ->
    #     node = new FakeNode
    #
    #     node.styles['height'] = '0'
    #
    #     morph(node)
    #       .andStyle('height', '100', 500)
    #       .go()
    #
    #     node.styles['height'].should.equal('0')
    #     clock.tick(250)
    #     node.styles['height'].should.equal('50')
    #     clock.tick(250)
    #     node.styles['height'].should.equal('100')
    #
    #   it 'andStyle should affect an elements styles (with start and end values)', ->
    #     node = new FakeNode
    #
    #     morph(node)
    #       .andStyle('height', '0', '100', undefined)
    #       .go()
    #
    #     node.styles['height'].should.equal('0')
    #     clock.tick(100)
    #     node.styles['height'].should.equal('50')
    #     clock.tick(100)
    #     node.styles['height'].should.equal('100')
    #
    #   it 'andStyle should affect an elements styles (with start and end values and custom duration)', ->
    #     node = new FakeNode
    #
    #     morph(node)
    #       .andStyle('height', '0', '100', 500)
    #       .go()
    #
    #     node.styles['height'].should.equal('0')
    #     clock.tick(250)
    #     node.styles['height'].should.equal('50')
    #     clock.tick(250)
    #     node.styles['height'].should.equal('100')
    #
    #   it 'thenStyle should affect an elements styles', ->
    #     node = new FakeNode
    #
    #     node.styles['height'] = '0'
    #
    #     morph(node)
    #       .thenStyle('height', '100')
    #       .go()
    #
    #     node.styles['height'].should.equal('0')
    #     clock.tick(100)
    #     node.styles['height'].should.equal('50')
    #     clock.tick(100)
    #     node.styles['height'].should.equal('100')
    #
    #   it 'thenStyle should affect an elements styles (with custom duration)', ->
    #     node = new FakeNode
    #
    #     node.styles['height'] = '0'
    #
    #     morph(node)
    #       .thenStyle('height', '100', 500)
    #       .go()
    #
    #     node.styles['height'].should.equal('0')
    #     clock.tick(250)
    #     node.styles['height'].should.equal('50')
    #     clock.tick(250)
    #     node.styles['height'].should.equal('100')
    #
    #   it 'thenStyle should affect an elements styles (with start and end values)', ->
    #     node = new FakeNode
    #
    #     morph(node)
    #       .thenStyle('height', '0', '100', undefined)
    #       .go()
    #
    #     node.styles['height'].should.equal('0')
    #     clock.tick(100)
    #     node.styles['height'].should.equal('50')
    #     clock.tick(100)
    #     node.styles['height'].should.equal('100')
    #
    #   it 'thenStyle should affect an elements styles (with start and end values and custom duration)', ->
    #     node = new FakeNode
    #
    #     morph(node)
    #       .thenStyle('height', '0', '100', 500)
    #       .go()
    #
    #     node.styles['height'].should.equal('0')
    #     clock.tick(250)
    #     node.styles['height'].should.equal('50')
    #     clock.tick(250)
    #     node.styles['height'].should.equal('100')
    #
    #   it 'andAttr should affect an elements attributes', ->
    #     node = new FakeNode
    #
    #     node.attrs['height'] = '0'
    #
    #     morph(node)
    #       .andAttr('height', '100')
    #       .go()
    #
    #     node.attrs['height'].should.equal('0')
    #     clock.tick(100)
    #     node.attrs['height'].should.equal('50')
    #     clock.tick(100)
    #     node.attrs['height'].should.equal('100')
    #
    #   it 'andAttr should affect an elements attributes (with custom duration)', ->
    #     node = new FakeNode
    #
    #     node.attrs['height'] = '0'
    #
    #     morph(node)
    #       .andAttr('height', '100', 500)
    #       .go()
    #
    #     node.attrs['height'].should.equal('0')
    #     clock.tick(250)
    #     node.attrs['height'].should.equal('50')
    #     clock.tick(250)
    #     node.attrs['height'].should.equal('100')
    #
    #   it 'andAttr should affect an elements attributes (with start and end values)', ->
    #     node = new FakeNode
    #
    #     morph(node)
    #       .andAttr('height', '0', '100', undefined)
    #       .go()
    #
    #     node.attrs['height'].should.equal('0')
    #     clock.tick(100)
    #     node.attrs['height'].should.equal('50')
    #     clock.tick(100)
    #     node.attrs['height'].should.equal('100')
    #
    #   it 'andAttr should affect an elements attributes (with start and end values and custom duration)', ->
    #     node = new FakeNode
    #
    #     morph(node)
    #       .andAttr('height', '0', '100', 500)
    #       .go()
    #
    #     node.attrs['height'].should.equal('0')
    #     clock.tick(250)
    #     node.attrs['height'].should.equal('50')
    #     clock.tick(250)
    #     node.attrs['height'].should.equal('100')
    #
    #   it 'thenAttr should affect an elements attributes', ->
    #     node = new FakeNode
    #
    #     node.attrs['height'] = '0'
    #
    #     morph(node)
    #       .thenAttr('height', '100')
    #       .go()
    #
    #     node.attrs['height'].should.equal('0')
    #     clock.tick(100)
    #     node.attrs['height'].should.equal('50')
    #     clock.tick(100)
    #     node.attrs['height'].should.equal('100')
    #
    #   it 'thenAttr should affect an elements attributes (with custom duration)', ->
    #     node = new FakeNode
    #
    #     node.attrs['height'] = '0'
    #
    #     morph(node)
    #       .thenAttr('height', '100', 500)
    #       .go()
    #
    #     node.attrs['height'].should.equal('0')
    #     clock.tick(250)
    #     node.attrs['height'].should.equal('50')
    #     clock.tick(250)
    #     node.attrs['height'].should.equal('100')
    #
    #   it 'thenAttr should affect an elements attributes (with start and end values)', ->
    #     node = new FakeNode
    #
    #     morph(node)
    #       .thenAttr('height', '0', '100', undefined)
    #       .go()
    #
    #     node.attrs['height'].should.equal('0')
    #     clock.tick(100)
    #     node.attrs['height'].should.equal('50')
    #     clock.tick(100)
    #     node.attrs['height'].should.equal('100')
    #
    #   it 'thenAttr should affect an elements attributes (with start and end values and custom duration)', ->
    #     node = new FakeNode
    #
    #     morph(node)
    #       .thenAttr('height', '0', '100', 500)
    #       .go()
    #
    #     node.attrs['height'].should.equal('0')
    #     clock.tick(250)
    #     node.attrs['height'].should.equal('50')
    #     clock.tick(250)
    #     node.attrs['height'].should.equal('100')
    #
    #  it 'withStyle should affect an elements attributes', ->
    #     node = new FakeNode
    #
    #     node.styles['height'] = '0'
    #
    #     morph(node)
    #       .withStyle('height', '100')
    #       .go()
    #
    #     node.styles['height'].should.equal('0')
    #     clock.tick(100)
    #     node.styles['height'].should.equal('50')
    #     clock.tick(100)
    #     node.styles['height'].should.equal('100')
    #
    #   it 'withStyle should affect an elements attributes (with custom duration)', ->
    #     node = new FakeNode
    #
    #     node.styles['height'] = '0'
    #
    #     morph(node)
    #       .withStyle('height', '100', 500)
    #       .go()
    #
    #     node.styles['height'].should.equal('0')
    #     clock.tick(250)
    #     node.styles['height'].should.equal('50')
    #     clock.tick(250)
    #     node.styles['height'].should.equal('100')
    #
    #   it 'withStyle should affect an elements attributes (with start and end values)', ->
    #     node = new FakeNode
    #
    #     morph(node)
    #       .withStyle('height', '0', '100', undefined)
    #       .go()
    #
    #     node.styles['height'].should.equal('0')
    #     clock.tick(100)
    #     node.styles['height'].should.equal('50')
    #     clock.tick(100)
    #     node.styles['height'].should.equal('100')
    #
    #   it 'withStyle should affect an elements attributes (with start and end values and custom duration)', ->
    #     node = new FakeNode
    #
    #     morph(node)
    #       .withStyle('height', '0', '100', 500)
    #       .go()
    #
    #     node.styles['height'].should.equal('0')
    #     clock.tick(250)
    #     node.styles['height'].should.equal('50')
    #     clock.tick(250)
    #     node.styles['height'].should.equal('100')
    #
    #   it 'withAttr should affect an elements attributes', ->
    #     node = new FakeNode
    #
    #     node.attrs['height'] = '0'
    #
    #     morph(node)
    #       .withAttr('height', '100')
    #       .go()
    #
    #     node.attrs['height'].should.equal('0')
    #     clock.tick(100)
    #     node.attrs['height'].should.equal('50')
    #     clock.tick(100)
    #     node.attrs['height'].should.equal('100')
    #
    #   it 'withAttr should affect an elements attributes (with custom duration)', ->
    #     node = new FakeNode
    #
    #     node.attrs['height'] = '0'
    #
    #     morph(node)
    #       .withAttr('height', '100', 500)
    #       .go()
    #
    #     node.attrs['height'].should.equal('0')
    #     clock.tick(250)
    #     node.attrs['height'].should.equal('50')
    #     clock.tick(250)
    #     node.attrs['height'].should.equal('100')
    #
    #   it 'withAttr should affect an elements attributes (with start and end values)', ->
    #     node = new FakeNode
    #
    #     morph(node)
    #       .withAttr('height', '0', '100', undefined)
    #       .go()
    #
    #     node.attrs['height'].should.equal('0')
    #     clock.tick(100)
    #     node.attrs['height'].should.equal('50')
    #     clock.tick(100)
    #     node.attrs['height'].should.equal('100')
    #
    #   it 'withAttr should affect an elements attributes (with start and end values and custom duration)', ->
    #     node = new FakeNode
    #
    #     morph(node)
    #       .withAttr('height', '0', '100', 500)
    #       .go()
    #
    #     node.attrs['height'].should.equal('0')
    #     clock.tick(250)
    #     node.attrs['height'].should.equal('50')
    #     clock.tick(250)
    #     node.attrs['height'].should.equal('100')
