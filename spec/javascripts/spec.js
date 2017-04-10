(function(){var extend=function(child,parent){function ctor(){this.constructor=child}for(var key in parent)hasProp.call(parent,key)&&(child[key]=parent[key]);return ctor.prototype=parent.prototype,child.prototype=new ctor,child.__super__=parent.prototype,child},hasProp={}.hasOwnProperty;describe("PinkmanCollection",function(){return it("exists",function(){return expect(PinkmanCollection).not.toBe(null)}),window.Dummy=function(superClass){function Dummy(){return Dummy.__super__.constructor.apply(this,arguments)}return extend(Dummy,superClass),Dummy.prototype.config={apiUrl:"/api/dummies"},Dummy}(PinkmanObject),window.Dummies=function(superClass){function Dummies(){return Dummies.__super__.constructor.apply(this,arguments)}return extend(Dummies,superClass),Dummies.prototype.config={apiUrl:"/api/dummies",memberClass:window.Dummy},Dummies}(PinkmanCollection),describe("Subclasses",function(){return it('Subclass has @pinkmanType == "collection"',function(){return expect(Dummies.pinkmanType).toBe("collection")})}),describe("Instances",function(){return it("Every instance has a unique pinkey (pinkman key / pinkman id)",function(){var a,b;return a=new PinkmanCollection,b=new Dummies,expect(a.pinkey).not.toBe(null),expect(b.pinkey).not.toBe(null),expect(a.pinkey).not.toEqual(b.pinkey)}),it("is pink",function(){var a;return a=new Dummies,expect(a.isPink).toBeTruthy()}),it("is in Pinkman.all",function(){var a;return a=new PinkmanCollection,expect(Pinkman.all).toContain(a)}),it("is in Pinkman.collections",function(){var a,b;return a=new PinkmanCollection,expect(Pinkman.collections).toContain(a),b=new Dummies,expect(Pinkman.collections).toContain(b)}),it('has pinkmanType == "collection"',function(){var a;return a=new Dummies,expect(a.pinkmanType).toEqual("collection")}),it('isCollection"',function(){var a;return a=new Dummies,expect(a.isCollection).toBeTruthy()})}),describe("Functions",function(){var collection,object;return collection=null,object=null,beforeEach(function(){return collection=new Dummies,object=new Dummy,object.set("a","b")}),describe("Predicate Functions",function(){return it("include: check if a object is in the collection",function(){var a;return a=new Dummy,collection.push(a),expect(collection.include(a)).toBeTruthy(),expect(collection.include(object)).toBeFalsy()}),it("include (id rule): if among the members, someone has the same id of the object passed, include returns true",function(){var a,b,c;return a=new Dummy,b=new Dummy,c=new Dummy,a.set("id",1),a.set("who","i am a."),b.set("id",1),b.set("who",'i am b! I am not a! I am not really in the collection but I have the same id of "a"! Yes I am a duplicated object.'),collection.push(a),expect(collection.include(a)).toBeTruthy(),expect(collection.include(b)).toBeTruthy()}),it("include (array version): check if all items of an array are in the collection",function(){var a,b,notInCollection;return a=new Dummy,b=new Dummy,notInCollection=new Dummy,collection.push([a,b,object]),expect(collection.include([a,b])).toBeTruthy(),expect(collection.include([a,object])).toBeTruthy(),expect(collection.include([b,object])).toBeTruthy(),expect(collection.include([notInCollection])).toBeFalsy()}),it("include: returns false for undefined object",function(){return expect(collection.include(null)).toBeFalsy()}),it("any: returns true iff there is at least one member",function(){return expect(collection.any()).toBeFalsy(),collection.push(object),expect(collection.any()).toBeTruthy()}),it("any: returns true iff any member satisfies a criteria (criteria(object) is true)",function(){var a,b,bullshit,thatIsTrue;return a=new Dummy,a.set("prettyHair","yes"),b=new Dummy,b.set("prettyHair","no"),collection.push(a),collection.push(b),thatIsTrue=collection.any(function(obj){return"yes"===obj.prettyHair}),bullshit=collection.any(function(obj){return"yes"===obj.prettyEyesAlso}),expect(thatIsTrue).toBeTruthy(),expect(bullshit).toBeFalsy()})}),describe("Info / Iterators /  Modifiers",function(){return it("count: return collection size",function(){var a;return expect(collection.count()).toEqual(0),collection.push(object),expect(collection.count()).toEqual(1),a=new Dummy,collection.push(a),expect(collection.count()).toEqual(2)}),it("size: count alias",function(){var a;return expect(collection.count()).toEqual(collection.size()),collection.push(object),expect(collection.count()).toEqual(collection.size()),a=new Dummy,collection.push(a),expect(collection.count()).toEqual(collection.size())}),it("length: count alias",function(){var a;return expect(collection.count()).toEqual(collection.length()),collection.push(object),expect(collection.count()).toEqual(collection.length()),a=new Dummy,collection.push(a),expect(collection.count()).toEqual(collection.length())}),it("count: accept a criteria function and returns a count of how many members satisfies it",function(){var a,b,count;return a=new Dummy,a.set("prettyHair","yes"),b=new Dummy,b.set("prettyHair","no"),collection.push(a),collection.push(b),count=collection.count(function(obj){return"yes"===obj.prettyHair}),expect(count).toEqual(1)}),it("each: apply a function to all members",function(){var a,i,len,obj,ref,results;for(a=new Dummy,collection.push(a),collection.push(object),collection.each(function(obj){return obj.set("each","transformed")}),ref=collection.collection,results=[],i=0,len=ref.length;i<len;i++)obj=ref[i],results.push(expect(obj.each).toEqual("transformed"));return results}),it("uniq: removes id duplicated members",function(){var a,b;return a=new Dummy({prettyHair:!0}),b=new Dummy({prettyHair:!1}),a.set("id",1),b.set("id",1),collection.collection=[a,b],expect(collection.uniq().include(b)).toBeFalsy()}),it("uniq: removes pinkey duplicated members",function(){var a,b;return a=new Dummy({prettyHair:!0}),b=new Dummy({prettyHair:!1}),b.set("pinkey",a.pinkey),collection.collection=[a,b],expect(collection.uniq().include(b)).toBeFalsy()})}),describe("Inserting elements",function(){return it("push: insert in last position",function(){var a;return a=new Dummy,collection.push(a),collection.push(object),expect(collection.last()).toBe(object)}),it("push: does not insert same object twice",function(){return collection.push(object),collection.push(object),collection.push([object,object]),expect(collection.count()).toEqual(1)}),it("push: return true on success, false otherwise",function(){return expect(collection.push(object)).toBeTruthy()}),it("unshift: insert in first position",function(){var a;return a=new Dummy,collection.unshift(a),collection.unshift(object),expect(collection.first()).toBe(object),expect(collection.last()).toBe(a)}),it("unshift: does not insert same object twice",function(){return collection.unshift(object),collection.unshift(object),collection.unshift([object,object]),expect(collection.count()).toEqual(1)}),it("unshift: return true on success, false otherwise",function(){return expect(collection.unshift(object)).toBeTruthy(),expect(collection.unshift(object)).toBeFalsy(),expect(collection.unshift(null)).toBeFalsy()}),it("fetchFromArray: gets every element of an array and inserts pinkman objects versions of them",function(){var a,b,c;return a=new Dummy,b=new Dummy,c={prettyHair:"yes"},collection.push([a,b,c]),expect(collection.include([a,b])).toBeTruthy(),expect(collection.getBy("prettyHair","yes").isPink).toBeTruthy(),expect(collection.getBy("prettyHair","yes").className()).toEqual("Dummy")}),it("beforeInsertionPrep: does nothing if object isPink",function(){var a;return a=new Dummy,expect(collection.beforeInsertionPrep(a)).toBe(a)}),it("beforeInsertionPrep: returns a pinkman version of the object",function(){var a,aPink,key,ref,results,value;a={prettyHair:"yes",prettyEyes:"no",prettyInteresting:"yes"},aPink=collection.beforeInsertionPrep(a),expect(a.isPink).toBeFalsy(),expect(aPink.isPink).toBeTruthy(),ref=aPink.attributes(),results=[];for(key in ref)value=ref[key],expect(Object.keys(a)).toContain(key),expect(aPink.keys()).toContain(key),results.push(expect(aPink[key]).toEqual(a[key]));return results}),it("beforeInsertionPrep: is called in push",function(){return spyOn(collection,"beforeInsertionPrep"),collection.push(object),expect(collection.beforeInsertionPrep).toHaveBeenCalled()}),it("beforeInsertionPrep: is called in unshift",function(){return spyOn(collection,"beforeInsertionPrep"),collection.unshift(object),expect(collection.beforeInsertionPrep).toHaveBeenCalled()}),it("beforeInsertionPrep: is called in fetchFromArray",function(){return spyOn(collection,"beforeInsertionPrep"),collection.fetchFromArray([object]),expect(collection.beforeInsertionPrep).toHaveBeenCalled()}),it("new: returns a new pinkman object associated to this collection",function(){var a;return a=collection["new"](),expect(a.isPink).toBeTruthy(),expect(a.className()).toEqual("Dummy")}),it("new: new object is in this collection",function(){var a;return a=collection["new"](),expect(collection.include(a)).toBeTruthy()})}),describe("Retrieving elements",function(){return it("first: return first object in this collection",function(){var a,b;return a=new Dummies,b=new Dummy,a.push(object),a.push(b),expect(a.first()).toBe(object)}),it("last: return last object in this collection",function(){var a,b;return a=new Dummies,b=new Dummy,a.push(object),a.push(b),expect(a.last()).toBe(b)}),it("get (1st usage format): get by pinkey if arg is a number (similar to getByPinkey function)",function(){var arg;return arg=1,spyOn(collection,"getByPinkey"),collection.get(arg),expect(collection.getByPinkey).toHaveBeenCalled()}),it("get (2nd usage format): get by attribute/value if arg is a pair of strings (similar to getBy function)",function(){var arg;return arg=["attribute","value"],spyOn(collection,"getBy"),collection.get.apply(collection,arg),expect(collection.getBy).toHaveBeenCalled()}),it("get (3rd usage format): get by multiples attributes/values of a object (arg is a object) (similar to getByAttributes function)",function(){var arg;return arg={attribute:"value"},spyOn(collection,"getByAttributes"),collection.get(arg),expect(collection.getByAttributes).toHaveBeenCalled()}),it("find: get an element by id",function(){var a,b;return a=new Dummy,a.set("id",1),b=new Dummy,collection.fetchFromArray([a,b]),expect(collection.find(1)).toBe(a)}),it("getByPinkey: get an element by pinkey",function(){var a,b;return a=new Dummy,b=new Dummy,collection.fetchFromArray([a,b]),expect(collection.getByPinkey(b.pinkey)).toBe(b)}),it("getBy: find the first element that matches (element.attribute = value)",function(){var a,b;return a=new Dummy,a.set("attribute","random"),b=new Dummy,b.set("attribute","random"),collection.fetchFromArray([a,b,object]),expect(collection.getBy("attribute","random")).toBe(a)}),it("getByAttributes: find the first element that matches (multiple keys & values version of getBy)",function(){var a,b;return a=new Dummy,a.set("attribute","random"),a.set("prettyHair","yes"),b=new Dummy,b.set("attribute","random"),b.set("prettyHair","no"),collection.fetchFromArray([a,b,object]),expect(collection.getByAttributes({attribute:"random",prettyHair:"yes"})).toBe(a)}),it("select: select/collect every member who satisfies a criteria (criteria(object) is true)",function(){var a,b,selection;return a=new Dummy,a.set("prettyHair","yes"),b=new Dummy,b.set("prettyHair","no"),collection.push(a),collection.push(b),selection=collection.select(function(obj){return"yes"===obj.prettyHair}),expect(selection.include(a)).toBeTruthy(),expect(selection.include(b)).toBeFalsy()}),it("select: accept a callback for the selection",function(){var a,b;return a=new Dummy,a.set("prettyHair","yes"),b=new Dummy,b.set("prettyHair","no"),collection.push(a),collection.push(b),collection.select(function(obj){return"yes"===obj.prettyHair},function(selection){return expect(selection.include(a)).toBeTruthy(),expect(selection.include(b)).toBeFalsy()})}),it("next: return next element",function(){var a,b;return a=new Dummy,a.set("prettyHair","yes"),b=new Dummy,b.set("prettyHair","no"),collection.push([a,b]),expect(collection.next(a)).toBe(b)}),it("prev: return previous element",function(){var a,b;return a=new Dummy,a.set("prettyHair","yes"),b=new Dummy,b.set("prettyHair","no"),collection.push([a,b]),expect(collection.prev(b)).toBe(a)})}),describe("Removing elements",function(){return it("pop: removes from last position and returns it",function(){var a;return a=new Dummy,collection.push(a),collection.push(object),expect(collection.pop()).toBe(object),expect(collection.include(object)).toBeFalsy(),expect(collection.include(a)).toBeTruthy()}),it("shift: removes from first position and returns it",function(){var a;return a=new Dummy,collection.push(a),collection.push(object),expect(collection.shift()).toBe(a),expect(collection.include(a)).toBeFalsy(),expect(collection.include(object)).toBeTruthy()}),it("remove: remove a object",function(){return collection.push(object),expect(collection.include(object)).toBeTruthy(),collection.remove(object),expect(collection.include(object)).toBeFalsy()}),it("remove: count subtracts 1",function(){return collection.push(object),expect(collection.count()).toEqual(1),collection.remove(object),expect(collection.count()).toEqual(0)}),it("removeBy: remove the first object that matches",function(){var removed;return removed=new Dummy,removed.set("yaba","dabadoo"),object.set("yaba","no-scooby-here"),collection.push(removed),collection.push(object),collection.removeBy("yaba","dabadoo"),expect(collection.include(removed)).toBeFalsy(),expect(collection.include(object)).toBeTruthy()}),it("removeAll: remove everyone",function(){var a;return a=new Dummy,collection.push(a),collection.push(object),expect(collection.include(a)).toBeTruthy(),expect(collection.include(object)).toBeTruthy(),expect(collection.removeAll()).toBeTruthy(),expect(collection.any()).toBeFalsy(),expect(collection.count()).toEqual(0),expect(collection.include(a)).toBeFalsy(),expect(collection.include(object)).toBeFalsy()})})})})}).call(this),function(){var extend=function(child,parent){function ctor(){this.constructor=child}for(var key in parent)hasProp.call(parent,key)&&(child[key]=parent[key]);return ctor.prototype=parent.prototype,child.prototype=new ctor,child.__super__=parent.prototype,child},hasProp={}.hasOwnProperty;describe("PinkmanCommon",function(){var Dummy;return Dummy=function(superClass){function Dummy(){return Dummy.__super__.constructor.apply(this,arguments)}return extend(Dummy,superClass),Dummy.prototype.config={apiUrl:"/api/dummy"},Dummy}(PinkmanCommon),describe("Class Scope/Functions",function(){return it("exists",function(){return expect(PinkmanCommon).not.toBe(null)}),it("@isInstance: return true if the object is a instance of this class",function(){var a;return a=new Dummy,expect(Dummy.isInstance(a)).toBeTruthy()})}),it("apiUrl: returns api url as expected (config object)",function(){var a;return a=new Dummy,expect(a.apiUrl()).toBe("/api/dummy")}),it("className: returns a string with the class name",function(){var a;return a=new Dummy,expect(a.className()).toBe("Dummy")}),it("isInstanceOf: return true if it is a instance of the passed class",function(){var a;return a=new Dummy,expect(a.isInstanceOf(Dummy)).toBeTruthy()}),it("set: sets a pair of key and value",function(){var a;return a=new Dummy,a.set("uhu","bozo"),expect(a.uhu).toEqual("bozo")}),it("set: triggers reRender if watch is true",function(){var a;return a=new Dummy,spyOn(a,"reRender"),a.set("watch",!0),a.set("a","b"),expect(a.reRender).toHaveBeenCalled()})})}.call(this),function(){describe("Dummy",function(){return it("just passes",function(){return expect(!0).toBe(!0)})})}.call(this),function(){var extend=function(child,parent){function ctor(){this.constructor=child}for(var key in parent)hasProp.call(parent,key)&&(child[key]=parent[key]);return ctor.prototype=parent.prototype,child.prototype=new ctor,child.__super__=parent.prototype,child},hasProp={}.hasOwnProperty;window.Dummy=function(superClass){function Dummy(){return Dummy.__super__.constructor.apply(this,arguments)}return extend(Dummy,superClass),Dummy.prototype.config={apiUrl:"/api/dummy"},Dummy}(PinkmanObject),describe("PinkmanObject",function(){return it("exists",function(){return expect(PinkmanObject).not.toBe(null)}),describe("Subclasses",function(){return it('Subclass has @pinkmanType == "object"',function(){return expect(Dummy.pinkmanType).toBe("object")})}),describe("Instances",function(){return it("Every instance of a PinkmanObject has a unique pinkey (pinkman key / pinkman id)",function(){var a,b;return a=new PinkmanObject,b=new Dummy,expect(a.pinkey).not.toBe(null),expect(b.pinkey).not.toBe(null),expect(a.pinkey).not.toEqual(b.pinkey)}),it("is pink",function(){var a;return a=new Dummy,expect(a.isPink).toBeTruthy()}),it("is in Pinkman.all",function(){var a;return a=new PinkmanObject,expect(Pinkman.all).toContain(a)}),it("is in Pinkman.objects",function(){var a;return a=new PinkmanObject,expect(Pinkman.objects).toContain(a)}),it('has pinkmanType == "object"',function(){var a;return a=new Dummy,expect(a.pinkmanType).toEqual("object")})}),describe("Functions",function(){var a;return a=null,beforeEach(function(){return a=new Dummy,a.set("a","b")}),it("assign: receives a js object and assigns its values",function(){var b;return a=new Dummy,b={attributeA:"a",attributeB:"b"},a.assign(b),expect(a.attributeA).toEqual("a"),expect(a.attributeB).toEqual("b")}),it("assign: does not substitute pinkman.objects by js.objects",function(){var attributes;return a=new Dummy,a.b=new Dummy,attributes={b:{something:"cool"}},a.assign(attributes),expect(a.b.isPink).toBeTruthy(),expect(a.b.something).toBe("cool")}),it("assign: does substitute pinkman.object by anything except js.objects",function(){var attributes;return a=new Dummy,a.b=new Dummy,attributes={b:"value"},a.assign(attributes),expect(a.b.isPink).not.toBeTruthy(),expect(a.b).toBe("value")}),it("attributes: returns a javascript object version",function(){return expect(a.attributes()).toEqual({a:"b"})}),it("attributesKeys: returns a array of keys",function(){return a.set("x","y"),expect(a.attributesKeys()).toEqual(["a","x"])}),it("attributesKeys: has an alias called keys",function(){return a.set("x","y"),expect(a.keys()).toEqual(a.attributesKeys())}),it("toString: returns a human readable string",function(){return a=new Dummy,a.set("a","b"),expect(a.toString()).toEqual("(Dummy) a: b;")})})})}.call(this);