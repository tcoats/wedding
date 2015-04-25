// Generated by CoffeeScript 1.9.1

/**
 * Copyright (c) 2010 Maxim Vasiliev
#
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
#
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
#
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
#
 * @author Maxim Vasiliev
 * Date: 09.09.2010
 * Time: 19:02:33
 */
(function(root, factory) {
  if (typeof exports !== 'undefined' && typeof module !== 'undefined' && module.exports) {
    module.exports = factory();
  } else if (typeof define === 'function' && define.amd) {
    define(factory);
  } else {
    root.form2js = factory();
  }
})(this, function() {

  /**
   * Returns form values represented as Javascript object
   * "name" attribute defines structure of resulting object
  #
   * @param rootNode {Element|String} root form element (or it's id) or array of root elements
   * @param delimiter {String} structure parts delimiter defaults to '.'
   * @param skipEmpty {Boolean} should skip empty text values, defaults to true
   * @param nodeCallback {Function} custom function to get node value
   * @param useIdIfEmptyName {Boolean} if true value of id attribute of field will be used if name of field is empty
   */
  var extractNodeValues, form2js, getFieldName, getFieldValue, getFormValues, getSelectedOptionValue, getSubFormValues, processNameValues;
  form2js = function(rootNode, delimiter, skipEmpty, nodeCallback, useIdIfEmptyName, getDisabled) {
    var currNode, formValues, i;
    getDisabled = getDisabled ? true : false;
    if (typeof skipEmpty === 'undefined' || skipEmpty === null) {
      skipEmpty = true;
    }
    if (typeof delimiter === 'undefined' || delimiter === null) {
      delimiter = '.';
    }
    if (arguments.length < 5) {
      useIdIfEmptyName = false;
    }
    rootNode = typeof rootNode === 'string' ? document.getElementById(rootNode) : rootNode;
    formValues = [];
    currNode = void 0;
    i = 0;

    /* If rootNode is array - combine values */
    if (rootNode.constructor === Array || typeof NodeList !== 'undefined' && rootNode.constructor === NodeList) {
      while (currNode = rootNode[i++]) {
        formValues = formValues.concat(getFormValues(currNode, nodeCallback, useIdIfEmptyName, getDisabled));
      }
    } else {
      formValues = getFormValues(rootNode, nodeCallback, useIdIfEmptyName, getDisabled);
    }
    return processNameValues(formValues, skipEmpty, delimiter);
  };

  /**
   * Processes collection of { name: 'name', value: 'value' } objects.
   * @param nameValues
   * @param skipEmpty if true skips elements with value == '' or value == null
   * @param delimiter
   */
  processNameValues = function(nameValues, skipEmpty, delimiter) {
    var _nameParts, arrIdx, arrName, arrNameFull, arrays, currResult, i, j, k, l, name, namePart, nameParts, result, value;
    result = {};
    arrays = {};
    i = void 0;
    j = void 0;
    k = void 0;
    l = void 0;
    value = void 0;
    nameParts = void 0;
    currResult = void 0;
    arrNameFull = void 0;
    arrName = void 0;
    arrIdx = void 0;
    namePart = void 0;
    name = void 0;
    _nameParts = void 0;
    i = 0;
    while (i < nameValues.length) {
      value = nameValues[i].value;
      if (skipEmpty && (value === '' || value === null)) {
        i++;
        continue;
      }
      name = nameValues[i].name;
      _nameParts = name.split(delimiter);
      nameParts = [];
      currResult = result;
      arrNameFull = '';
      j = 0;
      while (j < _nameParts.length) {
        namePart = _nameParts[j].split('][');
        if (namePart.length > 1) {
          k = 0;
          while (k < namePart.length) {
            if (k === 0) {
              namePart[k] = namePart[k] + ']';
            } else if (k === namePart.length - 1) {
              namePart[k] = '[' + namePart[k];
            } else {
              namePart[k] = '[' + namePart[k] + ']';
            }
            arrIdx = namePart[k].match(/([a-z_]+)?\[([a-z_][a-z0-9_]+?)\]/i);
            if (arrIdx) {
              l = 1;
              while (l < arrIdx.length) {
                if (arrIdx[l]) {
                  nameParts.push(arrIdx[l]);
                }
                l++;
              }
            } else {
              nameParts.push(namePart[k]);
            }
            k++;
          }
        } else {
          nameParts = nameParts.concat(namePart);
        }
        j++;
      }
      j = 0;
      while (j < nameParts.length) {
        namePart = nameParts[j];
        if (namePart.indexOf('[]') > -1 && j === nameParts.length - 1) {
          arrName = namePart.substr(0, namePart.indexOf('['));
          arrNameFull += arrName;
          if (!currResult[arrName]) {
            currResult[arrName] = [];
          }
          currResult[arrName].push(value);
        } else if (namePart.indexOf('[') > -1) {
          arrName = namePart.substr(0, namePart.indexOf('['));
          arrIdx = namePart.replace(/(^([a-z_]+)?\[)|(\]$)/gi, '');

          /* Unique array name */
          arrNameFull += '_' + arrName + '_' + arrIdx;

          /*
           * Because arrIdx in field name can be not zero-based and step can be
           * other than 1, we can't use them in target array directly.
           * Instead we're making a hash where key is arrIdx and value is a reference to
           * added array element
           */
          if (!arrays[arrNameFull]) {
            arrays[arrNameFull] = {};
          }
          if (arrName !== '' && !currResult[arrName]) {
            currResult[arrName] = [];
          }
          if (j === nameParts.length - 1) {
            if (arrName === '') {
              currResult.push(value);
              arrays[arrNameFull][arrIdx] = currResult[currResult.length - 1];
            } else {
              currResult[arrName].push(value);
              arrays[arrNameFull][arrIdx] = currResult[arrName][currResult[arrName].length - 1];
            }
          } else {
            if (!arrays[arrNameFull][arrIdx]) {
              if (/^[0-9a-z_]+\[?/i.test(nameParts[j + 1])) {
                currResult[arrName].push({});
              } else {
                currResult[arrName].push([]);
              }
              arrays[arrNameFull][arrIdx] = currResult[arrName][currResult[arrName].length - 1];
            }
          }
          currResult = arrays[arrNameFull][arrIdx];
        } else {
          arrNameFull += namePart;
          if (j < nameParts.length - 1) {
            if (!currResult[namePart]) {
              currResult[namePart] = {};
            }
            currResult = currResult[namePart];
          } else {
            currResult[namePart] = value;
          }
        }
        j++;
      }
      i++;
    }
    return result;
  };
  getFormValues = function(rootNode, nodeCallback, useIdIfEmptyName, getDisabled) {
    var result;
    result = extractNodeValues(rootNode, nodeCallback, useIdIfEmptyName, getDisabled);
    if (result.length > 0) {
      return result;
    } else {
      return getSubFormValues(rootNode, nodeCallback, useIdIfEmptyName, getDisabled);
    }
  };
  getSubFormValues = function(rootNode, nodeCallback, useIdIfEmptyName, getDisabled) {
    var currentNode, result;
    result = [];
    currentNode = rootNode.firstChild;
    while (currentNode) {
      result = result.concat(extractNodeValues(currentNode, nodeCallback, useIdIfEmptyName, getDisabled));
      currentNode = currentNode.nextSibling;
    }
    return result;
  };
  extractNodeValues = function(node, nodeCallback, useIdIfEmptyName, getDisabled) {
    var callbackResult, fieldName, fieldValue, result;
    if (node.disabled && !getDisabled) {
      return [];
    }
    callbackResult = void 0;
    fieldValue = void 0;
    result = void 0;
    fieldName = getFieldName(node, useIdIfEmptyName);
    callbackResult = nodeCallback && nodeCallback(node);
    if (callbackResult && callbackResult.name) {
      result = [callbackResult];
    } else if (fieldName !== '' && node.nodeName.match(/INPUT|TEXTAREA/i)) {
      fieldValue = getFieldValue(node, getDisabled);
      if (null === fieldValue) {
        result = [];
      } else {
        result = [
          {
            name: fieldName,
            value: fieldValue
          }
        ];
      }
    } else if (fieldName !== '' && node.nodeName.match(/SELECT/i)) {
      fieldValue = getFieldValue(node, getDisabled);
      result = [
        {
          name: fieldName.replace(/\[\]$/, ''),
          value: fieldValue
        }
      ];
    } else {
      result = getSubFormValues(node, nodeCallback, useIdIfEmptyName, getDisabled);
    }
    return result;
  };
  getFieldName = function(node, useIdIfEmptyName) {
    if (node.name && node.name !== '') {
      return node.name;
    } else if (useIdIfEmptyName && node.id && node.id !== '') {
      return node.id;
    } else {
      return '';
    }
  };
  getFieldValue = function(fieldNode, getDisabled) {
    if (fieldNode.disabled && !getDisabled) {
      return null;
    }
    switch (fieldNode.nodeName) {
      case 'INPUT':
      case 'TEXTAREA':
        switch (fieldNode.type.toLowerCase()) {
          case 'radio':
            if (fieldNode.checked && fieldNode.value === 'false') {
              return false;
            }
            break;
          case 'checkbox':
            if (fieldNode.checked && fieldNode.value === 'true') {
              return true;
            }
            if (!fieldNode.checked && fieldNode.value === 'true') {
              return false;
            }
            if (fieldNode.checked) {
              return fieldNode.value;
            }
            break;
          case 'button':
          case 'reset':
          case 'submit':
          case 'image':
            return '';
          default:
            return fieldNode.value;
            break;
        }
        break;
      case 'SELECT':
        return getSelectedOptionValue(fieldNode);
      default:
        break;
    }
    return null;
  };
  getSelectedOptionValue = function(selectNode) {
    var i, l, multiple, options, result;
    multiple = selectNode.multiple;
    result = [];
    options = void 0;
    i = void 0;
    l = void 0;
    if (!multiple) {
      return selectNode.value;
    }
    options = selectNode.getElementsByTagName('option');
    i = 0;
    l = options.length;
    while (i < l) {
      if (options[i].selected) {
        result.push(options[i].value);
      }
      i++;
    }
    return result;
  };
  'use strict';
  return form2js;
});
