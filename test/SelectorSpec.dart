import 'package:unittest/unittest.dart';
import 'jasmineSyntax.dart';
import '../src/angular.dart';
import 'dart:html';

main() {
  describe('Selector', () {
    //TODO(karma): throwing error here gets ignored
    // throw new Error();

    var log;
    var selector;
    var element;
    var directives;
    var e = (String html) {
      var div = new DivElement();
      div.innerHtml = html;
      return element = div.nodes.first;
    };

    beforeEach(() {
      // TODO(dart): why can't I have global noop?
      // TODO(dart): why does this not work?
      var noop = (Element e, String v) => null;

      log = [];
      directives = new Directives();
      directives.register('b', noop);
      directives.register('.b', noop);
      directives.register('[directive]', noop);
      directives.register('b[directive]', noop);
      directives.register('[directive=value]', noop);
      directives.register('b[directive=value]', noop);
      directives.register(':contains(/abc/)', noop);
      directives.register('[*=/xyz/]', noop);

      var directiveNames = directives.enumerate();
      selector = selectorFactory(directiveNames);
    });

    it('should match directive on element', () {
      expect(
        selector(e('<b></b>')),
        toEqualsDirectiveInfos([
          { "selector": 'b', "value": null, "element": element, "name": null }
        ]));
    });

    it('should match directive on class', () {
      expect(selector(e('<div class="a b c"></div>')),
        toEqualsDirectiveInfos([
          { "selector": '.b', "value": 'b', "element": element, "name": 'class' }
      ]));
    });


    it('should match directive on [attribute]', () {
      expect(selector(e('<div directive=abc></div>')),
        toEqualsDirectiveInfos([
          { "selector": '[directive]', "value": 'abc', "element": element,
            "name": 'directive' }]));

      expect(selector(e('<div directive></div>')),
        toEqualsDirectiveInfos([
          { "selector": '[directive]', "value": '', "element": element,
            "name": 'directive' }]));
    });


    it('should match directive on element[attribute]', () {
      expect(selector(e('<b directive=abc></b>')),
        toEqualsDirectiveInfos([
          { "selector": 'b', "value": null, "element": element, "name": null},
          { "selector": 'b[directive]', "value": 'abc', "element": element, "name": 'directive'},
          { "selector": '[directive]', "value": 'abc', "element": element, "name": 'directive'}
        ]));
    });


    it('should match directive on [attribute=value]', () {
      expect(selector(e('<div directive=value></div>')),
        toEqualsDirectiveInfos([
          { "selector": '[directive]', "value": 'value', "element": element, "name": 'directive'},
          { "selector": '[directive=value]', "value": 'value', "element": element, "name": 'directive'}
        ]));
    });


    it('should match directive on element[attribute=value]', () {
      expect(selector(e('<b directive=value></div>')),
        toEqualsDirectiveInfos([
          { "selector": 'b', "value": null, "element": element, "name": null},
          { "selector": 'b[directive]', "value": 'value', "element": element, "name": 'directive'},
          { "selector": 'b[directive=value]', "value": 'value', "element": element, "name": 'directive'},
          { "selector": '[directive]', "value": 'value', "element": element, "name": 'directive'},
          { "selector": '[directive=value]', "value": 'value', "element": element, "name": 'directive'}
        ]));
    });

    it('should match attributes', () {
      expect(selector(e('<div attr="before-xyz-after"></div>')),
        toEqualsDirectiveInfos([
          { "selector": '[*=/xyz/]', "value": 'attr=before-xyz-after',
            "element": element, "name": 'attr'}
        ]));
    });

    it('should match text', () {
      expect(selector(e('before-abc-after')),
        toEqualsDirectiveInfos([
          { "selector": ':contains(/abc/)', "value": 'before-abc-after',
            "element": element, "name": '#text'}
        ]));
    });
  });
}


class DirectiveInfosMatcher extends BaseMatcher {
  List<Map> expected;

  DirectiveInfosMatcher(this.expected);

  Description describe(Description description) {
    description.add(expected.toString());
    return description;
  }

  bool matches(directiveInfos, MatchState matchState) {
    var pass = expected.length == directiveInfos.length;
    if (pass) {
      for(var i = 0, ii = expected.length; i < ii; i++) {
        var directiveInfo = directiveInfos[i];
        var expectedMap = expected[i];

        pass = pass &&
          directiveInfo.element == expectedMap['element'] &&
          directiveInfo.selector == expectedMap['selector'] &&
          directiveInfo.name == expectedMap['name'] &&
          directiveInfo.value == expectedMap['value'];
      }
    }
    return pass;
  }
}

Matcher toEqualsDirectiveInfos(List<Map> directives) {
  return new DirectiveInfosMatcher(directives);
}

