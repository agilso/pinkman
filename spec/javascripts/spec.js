(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  describe('PinkmanCollection', function() {
    var Dummies, Dummy;
    it('exists', function() {
      return expect(PinkmanCollection).not.toBe(null);
    });
    Dummies = (function(superClass) {
      extend(Dummies, superClass);

      function Dummies() {
        return Dummies.__super__.constructor.apply(this, arguments);
      }

      Dummies.prototype.config = {
        apiUrl: '/api/dummies'
      };

      return Dummies;

    })(PinkmanCollection);
    Dummy = (function(superClass) {
      extend(Dummy, superClass);

      function Dummy() {
        return Dummy.__super__.constructor.apply(this, arguments);
      }

      Dummy.prototype.config = {
        apiUrl: '/api/dummies'
      };

      return Dummy;

    })(PinkmanObject);
    describe('Subclasses', function() {
      return it('Subclass has @pinkmanType == "collection"', function() {
        return expect(Dummies.pinkmanType).toBe('collection');
      });
    });
    describe('Instances', function() {
      it('Every instance has a unique pinkey (pinkman key / pinkman id)', function() {
        var a, b;
        a = new PinkmanCollection;
        b = new Dummies;
        expect(a.pinkey).not.toBe(null);
        expect(b.pinkey).not.toBe(null);
        return expect(a.pinkey).not.toEqual(b.pinkey);
      });
      it('is pink', function() {
        var a;
        a = new Dummies;
        return expect(a.isPink).toBeTruthy;
      });
      it('is in Pinkman.all', function() {
        var a;
        a = new PinkmanCollection;
        return expect(Pinkman.all).toContain(a);
      });
      it('is in Pinkman.objects', function() {
        var a, b;
        a = new PinkmanCollection;
        expect(Pinkman.collections).toContain(a);
        b = new Dummies;
        return expect(Pinkman.collections).toContain(b);
      });
      return it('has pinkmanType == "collection"', function() {
        var a;
        a = new Dummies;
        return expect(a.pinkmanType).toEqual('collection');
      });
    });
    return describe('Functions', function() {
      var collection, object;
      collection = null;
      object = null;
      beforeEach(function() {
        collection = new Dummies;
        object = new Dummy;
        return object.set('a', 'b');
      });
      it('count: return collection size', function() {
        var a;
        expect(collection.count()).toEqual(0);
        collection.push(object);
        expect(collection.count()).toEqual(1);
        a = new Dummy;
        collection.push(a);
        return expect(collection.count()).toEqual(2);
      });
      it('size: count alias', function() {
        var a;
        expect(collection.count()).toEqual(collection.size());
        collection.push(object);
        expect(collection.count()).toEqual(collection.size());
        a = new Dummy;
        collection.push(a);
        return expect(collection.count()).toEqual(collection.size());
      });
      it('length: count alias', function() {
        var a;
        expect(collection.count()).toEqual(collection.length());
        collection.push(object);
        expect(collection.count()).toEqual(collection.length());
        a = new Dummy;
        collection.push(a);
        return expect(collection.count()).toEqual(collection.length());
      });
      it('count: accepts a criteria function and returns a count of how many members satisfies it', function() {
        var a, b, count;
        a = new Dummy;
        a.set('prettyHair', 'yes');
        b = new Dummy;
        b.set('prettyHair', 'no');
        collection.push(a);
        collection.push(b);
        count = collection.count(function(obj) {
          return obj.prettyHair === 'yes';
        });
        return expect(count).toEqual(1);
      });
      it('first: returns first object in this collection', function() {
        var a, b;
        a = new Dummies;
        b = new Dummy;
        a.push(object);
        a.push(b);
        return expect(a.first()).toBe(object);
      });
      it('last: returns last object in this collection', function() {
        var a, b;
        a = new Dummies;
        b = new Dummy;
        a.push(object);
        a.push(b);
        return expect(a.last()).toBe(b);
      });
      it('push: inserts in last position', function() {
        var a;
        a = new Dummy;
        collection.push(a);
        collection.push(object);
        return expect(collection.last()).toBe(object);
      });
      return it('each: apply a function to all members', function() {
        var a, i, len, obj, ref, results;
        a = new Dummy;
        collection.push(a);
        collection.push(object);
        collection.each(function(obj) {
          return obj.set('each', 'transformed');
        });
        ref = collection.collection;
        results = [];
        for (i = 0, len = ref.length; i < len; i++) {
          obj = ref[i];
          results.push(expect(obj.each).toEqual('transformed'));
        }
        return results;
      });
    });
  });

}).call(this);
(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  describe('PinkmanCommon', function() {
    var Dummy;
    it('exists', function() {
      return expect(PinkmanCommon).not.toBe(null);
    });
    Dummy = (function(superClass) {
      extend(Dummy, superClass);

      function Dummy() {
        return Dummy.__super__.constructor.apply(this, arguments);
      }

      Dummy.prototype.config = {
        apiUrl: '/api/dummy'
      };

      return Dummy;

    })(PinkmanCommon);
    it('apiUrl: returns api url as expected (config object)', function() {
      var a;
      a = new Dummy;
      return expect(a.apiUrl()).toBe('/api/dummy');
    });
    it('className: returns a string with the class name', function() {
      var a;
      a = new Dummy;
      return expect(a.className()).toBe('Dummy');
    });
    it('set: sets a pair of key and value', function() {
      var a;
      a = new Dummy;
      a.set('uhu', 'bozo');
      return expect(a.uhu).toEqual('bozo');
    });
    return it('set: triggers reRender if watch is true', function() {
      var a;
      a = new Dummy;
      spyOn(a, 'reRender');
      a.set('watch', true);
      a.set('a', 'b');
      return expect(a.reRender).toHaveBeenCalled();
    });
  });

}).call(this);
(function() {
  describe('Dummy', function() {
    return it('just passes', function() {
      return expect(true).toBe(true);
    });
  });

}).call(this);
(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  window.Dummy = (function(superClass) {
    extend(Dummy, superClass);

    function Dummy() {
      return Dummy.__super__.constructor.apply(this, arguments);
    }

    Dummy.prototype.config = {
      apiUrl: '/api/dummy'
    };

    return Dummy;

  })(PinkmanObject);

  describe('PinkmanObject', function() {
    it('exists', function() {
      return expect(PinkmanObject).not.toBe(null);
    });
    describe('Subclasses', function() {
      return it('Subclass has @pinkmanType == "object"', function() {
        return expect(Dummy.pinkmanType).toBe('object');
      });
    });
    describe('Instances', function() {
      it('Every instance of a PinkmanObject has a unique pinkey (pinkman key / pinkman id)', function() {
        var a, b;
        a = new PinkmanObject;
        b = new Dummy;
        expect(a.pinkey).not.toBe(null);
        expect(b.pinkey).not.toBe(null);
        return expect(a.pinkey).not.toEqual(b.pinkey);
      });
      it('is pink', function() {
        var a;
        a = new Dummy;
        return expect(a.isPink).toBeTruthy;
      });
      it('is in Pinkman.all', function() {
        var a;
        a = new PinkmanObject;
        return expect(Pinkman.all).toContain(a);
      });
      it('is in Pinkman.objects', function() {
        var a;
        a = new PinkmanObject;
        return expect(Pinkman.objects).toContain(a);
      });
      return it('has pinkmanType == "object"', function() {
        var a;
        a = new Dummy;
        return expect(a.pinkmanType).toEqual('object');
      });
    });
    return describe('Functions', function() {
      var a;
      a = null;
      beforeEach(function() {
        a = new Dummy;
        return a.set('a', 'b');
      });
      it('assign: receives a js object and assigns its values', function() {
        var b;
        a = new Dummy;
        b = {
          attributeA: 'a',
          attributeB: 'b'
        };
        a.assign(b);
        expect(a.attributeA).toEqual('a');
        return expect(a.attributeB).toEqual('b');
      });
      it('assign: does not substitute pinkman.objects by js.objects', function() {
        var attributes;
        a = new Dummy;
        a.b = new Dummy;
        attributes = {
          b: {
            something: 'cool'
          }
        };
        a.assign(attributes);
        expect(a.b.isPink).toBeTruthy;
        return expect(a.b.something).toBe('cool');
      });
      it('assign: does substitute pinkman.object by anything except js.objects', function() {
        var attributes;
        a = new Dummy;
        a.b = new Dummy;
        attributes = {
          b: 'value'
        };
        a.assign(attributes);
        expect(a.b.isPink).not.toBeTruthy;
        return expect(a.b).toBe('value');
      });
      it('attributes: returns a javascript object version', function() {
        return expect(a.attributes()).toEqual({
          'a': 'b'
        });
      });
      it('attributesKeys: returns a array of keys', function() {
        a.set('x', 'y');
        return expect(a.attributesKeys()).toEqual(['a', 'x']);
      });
      it('attributesKeys: has an alias called keys', function() {
        a.set('x', 'y');
        return expect(a.keys()).toEqual(a.attributesKeys());
      });
      return it('toString: returns a human readable string', function() {
        a = new Dummy;
        a.set('a', 'b');
        return expect(a.toString()).toEqual('(Dummy) a: b;');
      });
    });
  });

}).call(this);
