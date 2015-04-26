// Generated by CoffeeScript 1.9.1
var Emblem, component, inject, ref, svg;

ref = require('odojs'), svg = ref.svg, component = ref.component;

inject = require('injectinto');

require('svg4everybody');

Emblem = component({
  render: function() {
    return svg('svg', {
      attributes: {
        role: 'img',
        "class": 'emblem'
      }
    }, [
      svg('use', {
        'xlink:href': "/dist/wedding-1.0.0.min.svg#emblem"
      })
    ]);
  }
});

inject.bind('emblem', Emblem);

module.exports = Emblem;
