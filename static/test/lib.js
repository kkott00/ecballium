// Generated by CoffeeScript 1.6.2
(function() {
  ecballiumbot.register_handlers([
    [
      /^Find (.+) with (.*)/, /^Найти (.+) c (.*)/, /^Find (.+)/, function(type, par) {
        type = this.A(type);
        par = this.A(par);
        console.log('find', type, par);
        this.ecb.found_item = $(type, this.root);
        console.log('sel', this.ecb.found_item);
        if (par) {
          this.ecb.found_item = this.ecb.found_item.filter(":contains(" + par + ")");
        }
        console.log('sel', this.ecb.found_item);
        this.assert(this.ecb.found_item.length, 'Not found item');
        this.mouse.movetoobj(this.ecb.found_item);
        return this.done();
      }
    ], [
      /^Click found item/, /^Click it/, /^Кликнуть на найденом/, function() {
        var _this = this;

        return this.mouse.trueClick(this.ecb.found_item).done(function() {
          return _this.done('success');
        });
      }
    ], [
      /^Say "([^"]+)"/, /^Комментарий "([^"]+)"/, function(say) {
        var _this = this;

        return this.mouse.say(say).done(function() {
          return _this.done('success');
        });
      }
    ], [
      /^(\w+) animation/, /^(\w+) анимацию/, function(state) {
        this.animation = state === "Enable" ? true : false;
        return this.mouse.enable(this.animation);
      }
    ], [
      /^Highlight and say "([^"]+)"/, /^Выделить и добавить комментарий "([^"]+)"/, function(comment) {
        var d, item, item_pos, old,
          _this = this;

        item = this.ecb.found_item;
        old = this.mouse.dump_css(item, {
          'z-index': 10001,
          'position': 'relative',
          'background-color': 'white'
        });
        item_pos = item.first().offset();
        d = this.mouse.show_message(item_pos.left, item_pos.top + item.outerHeight() + 5, comment);
        return d.done(function() {
          item.css(old);
          return _this.done('success');
        });
      }
    ], [
      /^(Check|Stop) if (.+) (are|is|aren\'t|isn\'t) (.+)/, /^(Проверить|Остановиться) если (.+) (-|не) (.+)/, function(action, sel, cond, val) {
        var assertion, res;

        if (sel === 'text') {
          res = this.ecb.found_item.text() === val;
        } else {
          res = this.ecb.found_item.css(this.A(el)) === val;
        }
        if ((this.A(cond)) === "isn't") {
          res = !res;
        }
        assertion = "check for for " + sel + " with value " + val;
        if ((this.A(action)) === 'Check') {
          this.assert(res, assertion);
        } else {
          this.fail(res, assertion);
        }
        return this.mouse.movetoobj(f.first());
      }
    ], [
      /^Switch to frame (.+)/, function(num) {
        this.console.log('sframe', num);
        this.root = this.window.frames[num].document;
        return this.done('success');
      }
    ], [
      /^Switch to (.*)/, /^Переключиться на (.*)/, function(awhere) {
        var where;

        where = this.A(awhere);
        if (where === 'found item' || where === 'it') {
          this.root = this.found_item.first();
        } else {
          this.root = $(document);
        }
        if (this.root.is('iframe')) {
          this.root = this.root.contents();
        }
        return null;
      }
    ], [
      /^Enter "([^"]+)"/, /^Ввести "([^"]+)"/, function(text) {
        this.ecb.found_item.val(text);
        return this.done('success');
      }
    ], [
      /^Wait ([^"]+) seconds/, /^Подождать ([^"]+)/, function(sec) {
        this.ecb.after_step_delay = sec * 1000;
        return this.done('success');
      }
    ], [
      /^Go to (.+)/, function(url) {
        var new_link, where,
          _this = this;

        this.console.log('gotoh', url);
        where = this.A(url);
        this.onredirect = function() {
          return null;
        };
        this.ecb.after_step_delay = 2 * 1000;
        this.console.log('gotoh', where);
        new_link = this.ecb.URL + '/' + where;
        this.window.location.assign(new_link);
        setTimeout(function() {
          return _this.window.location.reload();
        }, 300);
        return null;
      }
    ], [
      /^Stop on any problem/, function() {
        this.ecb.stop_on_any = true;
        return this.done('success');
      }
    ], [
      /^Run feature (.*)/, function(f) {
        this.ecb.pending_feature = f;
        return this.done('run_feature');
      }
    ], [
      /^Scroll to it/, function() {
        var d,
          _this = this;

        d = $('html, body').animate({
          scrollTop: $(this.ecb.found_item).offset().top
        }, 500);
        return d.complete(function() {
          return _this.done('success');
        });
      }
    ], []
  ]);

  ecballiumbot.register_aliases({
    'has': 'have',
    "doesn't have": "don't have",
    'имеет': 'have',
    'не имеет': "don't have",
    'Проверить': 'Check',
    'Остановиться': 'Fail',
    'button': 'button',
    'link': 'a',
    "ссылку": 'a',
    "кнопку": 'button',
    "anything with text": '',
    "все с текстом": '',
    "frame": "iframe",
    "are": 'is',
    "aren't": "isn't",
    '-': 'is',
    'не': "isn't",
    'найденный элемент': 'found item',
    'документ': 'document',
    'header': 'h1, h2, h3, h4, h5',
    'image': 'img',
    'фрейм': 'frame'
  });

}).call(this);
