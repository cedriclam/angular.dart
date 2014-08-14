library event_handler_spec;

import '../_specs.dart';

@Controller(selector: '[foo]', publishAs: 'ctrl')
class FooController {
  var description = "desc";
  var invoked = false;
}

@Component(selector: 'bar',
    template: '''
              <div>
                <span on-abc="ctrl.invoked=true;"></span>
                <content></content>
              </div>
              ''',
    publishAs: 'ctrl')
class BarComponent {
  var invoked = false;
  BarComponent(RootScope scope) {
    scope.context['barComponent'] = this;
  }
}

main() {
  describe('EventHandler', () {
    beforeEachModule((Module module) {
      module..bind(FooController)
            ..bind(BarComponent);
    });


    it('should register and handle event', (TestBed _, Application app) {
      var e = _.compile(
        '''<div foo>
          <div on-abc="ctrl.invoked=true"></div>
        </div>''');
      document.body.append(app.element..append(e));

      _.triggerEvent(e.querySelector('[on-abc]'), 'abc');
      expect(_.getScope(e).context['ctrl'].invoked).toEqual(true);
    });

    it('shoud register and handle event with long name', (TestBed _, Application app) {
      var e = _.compile(
        '''<div foo>
          <div on-my-new-event="ctrl.invoked=true"></div>
        </div>''');
      document.body.append(app.element..append(e));

      _.triggerEvent(e.querySelector('[on-my-new-event]'), 'myNewEvent');
      var fooScope = _.getScope(e);
      expect(fooScope.context['ctrl'].invoked).toEqual(true);
    });

    it('should have model updates applied correctly', (TestBed _, Application app) {
      var e = _.compile(
        '''<div foo>
          <div on-abc='ctrl.description="new description"'>{{ctrl.description}}</div>
        </div>''');
      document.body.append(app.element..append(e));
      var el = document.querySelector('[on-abc]');
      el.dispatchEvent(new Event('abc'));
      _.rootScope.apply();
      expect(el.text).toEqual("new description");
    });

    it('should register event when shadow dom is used', async((TestBed _, Application app) {
      var e = _.compile('<bar></bar>');
      document.body.append(app.element..append(e));

      microLeap();

      var shadowRoot = e.shadowRoot;
      var span = shadowRoot.querySelector('span');
      span.dispatchEvent(new CustomEvent('abc'));
      BarComponent ctrl = _.rootScope.context['barComponent'];
      expect(ctrl.invoked).toEqual(true);
    }));

    it('shoud handle event within content only once', async((TestBed _, Application app) {
      var e = _.compile(
        '''<div foo>
             <bar>
               <div on-abc="ctrl.invoked=true;"></div>
             </bar>
           </div>''');
      document.body.append(app.element..append(e));

      microLeap();

      document.querySelector('[on-abc]').dispatchEvent(new Event('abc'));
      var shadowRoot = document.querySelector('bar').shadowRoot;
      var shadowRootScope = _.getScope(shadowRoot);
      BarComponent ctrl = shadowRootScope.context['ctrl'];
      expect(ctrl.invoked).toEqual(false);

      var fooScope = _.getScope(document.querySelector('[foo]'));
      expect(fooScope.context['ctrl'].invoked).toEqual(true);
    }));
  });
}
