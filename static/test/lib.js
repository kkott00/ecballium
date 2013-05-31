// Generated by CoffeeScript 1.6.2
(function() {
  var __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

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
        } else if (sel === 'value') {
          res = this.ecb.found_item.value() === val;
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
        this.ecb.after_step_delay = 1000;
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
      /^Load library (.*)/, function(lib) {
        this.ecb.scripts.push(lib);
        return this.done('load_library');
      }
    ], [
      /^Scroll to it/, function() {
        var d,
          _this = this;

        d = this.mouse.scrollTo(this.ecb.found_item);
        return d.complete(function() {
          return _this.done('success');
        });
      }
    ], [
      /^Fill form/, function() {
        var i, inp, j, opts, _i, _j, _len, _len1, _ref, _ref1, _ref2;

        _ref = this.ecb.current_step.data;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          i = _ref[_i];
          inp = this.ecb.found_item.find("[name=" + i[0] + "]");
          if (inp.attr('type') === 'radio') {
            opts = i[1].split(',,');
            for (_j = 0, _len1 = inp.length; _j < _len1; _j++) {
              j = inp[_j];
              j.checked = (_ref1 = $(j).attr('value'), __indexOf.call(opts, _ref1) >= 0) ? true : false;
            }
          } else if (inp.attr('type') === 'checkbox') {
            inp[0].checked = (_ref2 = i[1]) === 'checked' || _ref2 === 'check' ? true : false;
          } else if (inp.is('select')) {
            opts = i[1].split(',,');
            inp.find("option").filter(function() {
              var _ref3;

              return _ref3 = $(this).val(), __indexOf.call(opts, _ref3) >= 0;
            }).prop('selected', true);
          } else {
            inp.val(i[1]);
          }
        }
        return this.done('success');
      }
    ], [
      /^Set select options/, function() {
        var i, j, opts, _i, _len, _ref, _ref1;

        opts = (function() {
          var _i, _len, _ref, _results;

          _ref = this.ecb.current_step.data;
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            i = _ref[_i];
            _results.push(i[0]);
          }
          return _results;
        }).call(this);
        console.log('select', opts);
        _ref = this.ecb.found_item.find('option');
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          j = _ref[_i];
          j.selected = (_ref1 = $(j).attr('value'), __indexOf.call(opts, _ref1) >= 0);
        }
        this.ecb.after_step_delay = 1000;
        return this.done('success');
      }
    ], [
      /^Set radio to (.+)/, function(opt) {
        var j, _i, _len, _ref;

        _ref = this.ecb.found_item;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          j = _ref[_i];
          j.checked = $(j).attr('value') === opt ? true : false;
        }
        this.ecb.after_step_delay = 1000;
        return this.done('success');
      }
    ]
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
    'фрейм': 'frame',
    'text input': 'input[type=text]',
    'checkbox': 'input[type=checkbox]',
    'radio': 'input[type=radio]'
  });

}).call(this);
