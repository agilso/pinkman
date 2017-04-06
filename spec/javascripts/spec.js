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
        return expect(a.isPink).toBe(true);
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
      it('apiUrl: returns api url as expected (config object)', function() {
        a = new Dummy;
        return expect(a.apiUrl()).toBe('/api/dummy');
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
        expect(a.b.isPink).toBe(true);
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
        expect(a.b.isPink).not.toBe(true);
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
      it('className: returns a string with the class name', function() {
        a = new Dummy;
        return expect(a.className()).toBe('Dummy');
      });
      it('set: sets a pair of key and value', function() {
        a = new Dummy;
        a.set('uhu', 'bozo');
        return expect(a.uhu).toEqual('bozo');
      });
      it('set: triggers reRender if watch is true', function() {
        a = new Dummy;
        spyOn(a, 'reRender');
        a.set('watch', true);
        a.set('a', 'b');
        return expect(a.reRender).toHaveBeenCalled();
      });
      return it('toString: returns a human readable string', function() {
        a = new Dummy;
        a.set('a', 'b');
        return expect(a.toString()).toEqual('(Dummy) a: b;');
      });
    });
  });

}).call(this);
