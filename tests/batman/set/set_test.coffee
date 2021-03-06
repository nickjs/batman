setTestSuite = ->
  test "isEmpty() on an empty set returns true", ->
    ok @set.isEmpty()
    ok @set.get 'isEmpty'

  test "has(item) on an empty set returns false", ->
    equal @set.has('foo'), false

  test "has(undefined) returns false", ->
    equal @set.has(undefined), false

  test "add(items...) adds the items to the set, such that has(item) returns true for each item, and increments the set's length accordingly", ->
    deepEqual @set.add('foo', 'bar'), ['foo', 'bar']
    equal @set.length, 2
    equal @set.has('foo'), true
    equal @set.has('bar'), true

  test "add(items...) only increments length for items which weren't already there, and only returns items which weren't already there", ->
    deepEqual @set.add('foo'), ['foo']
    deepEqual @set.add('foo', 'bar'), ['bar']
    deepEqual @set.add('baz', 'baz'), ['baz']

    equal @set.length, 3

  test "remove(items...) removes the items from the set, returning the item and not touching any others", ->
    @set.add('foo', o1={}, o2={}, o3={})

    deepEqual @set.remove(o2, o3), [o2, o3]

    equal @set.length, 2
    equal @set.has('foo'), true
    equal @set.has(o1), true
    equal @set.has(o2), false
    equal @set.has(o3), false

  test "remove(items...) returns an array of only the items that were there in the first place", ->
    @set.add('foo')
    @set.add('baz')

    deepEqual @set.remove('foo', 'bar'), ['foo']
    deepEqual @set.remove('foo'), []

  test "remove(items...) only decrements length for items that are there to be removed", ->
    @set.add('foo', 'bar', 'baz')
    @set.remove('foo', 'qux')
    @set.remove('bar', 'bar')

    equal @set.length, 1

  test "merge(other) returns a merged set without changing the original", ->
    @set.add('foo', 'bar', 'baz')
    other = new Batman.Set
    other.add('qux', 'buzz')
    merged = @set.merge(other)

    for v in ['foo', 'bar', 'baz', 'qux', 'buzz']
      ok merged.has(v)
    equal merged.length, 5

    ok !@set.has('qux')
    ok !@set.has('buzz')

  test "add(items...) fires length observers", ->
    @set.observe 'length', spy = createSpy()
    @set.add('foo')
    deepEqual spy.lastCallArguments, [1, 0]

    @set.add('baz', 'bar')
    deepEqual spy.lastCallArguments, [3, 1]

    equal spy.callCount, 2
    @set.add('bar')
    equal spy.callCount, 2

  test "remove(items...) fires length observers", ->
    @set.observe 'length', spy = createSpy()
    @set.add('foo')
    @set.remove('foo')
    deepEqual spy.lastCallArguments, [0, 1]

    equal spy.callCount, 2
    @set.remove('foo')
    equal spy.callCount, 2

  test "clear() fires length observers", ->
    spy = createSpy()
    @set.observe('length', spy)

    @set.add('foo', 'bar')
    @set.clear()
    equal spy.callCount, 2, 'clear() fires length observers'

  test "filter() returnes a set", ->
    @set.add 'foo', 'bar', 'baz'

    @filtered = @set.filter (v) -> v.slice(0, 1) is 'b'
    ok @filtered.constructor == @set.constructor
    equal @filtered.length, 2
    ok @filtered.has 'bar'
    ok @filtered.has 'baz'

  test "indexedBy(key) returns a memoized Batman.SetIndex for that key", ->
    index = @set.indexedBy('length')
    ok index instanceof Batman.SetIndex
    equal index.base, @set
    equal index.key, 'length'
    strictEqual @set.indexedBy('length'), index

  test "get('indexedBy.someKey') returns the same index as indexedBy(key)", ->
    strictEqual @set.get('indexedBy.length'), @set.indexedBy('length')

QUnit.module 'Batman.Set',
  setup: ->
    @set = new Batman.Set

setTestSuite()

QUnit.module 'Batman.SortableSet',
  setup: ->
    @set = new Batman.SortableSet

setTestSuite()
