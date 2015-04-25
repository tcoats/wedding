###*
# Copyright (c) 2010 Maxim Vasiliev
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# @author Maxim Vasiliev
# Date: 09.09.2010
# Time: 19:02:33
###

((root, factory) ->
  if typeof exports != 'undefined' and typeof module != 'undefined' and module.exports
    # NodeJS
    module.exports = factory()
  else if typeof define == 'function' and define.amd
    # AMD. Register as an anonymous module.
    define factory
  else
    # Browser globals
    root.form2js = factory()
  return
) this, ->

  ###*
  # Returns form values represented as Javascript object
  # "name" attribute defines structure of resulting object
  #
  # @param rootNode {Element|String} root form element (or it's id) or array of root elements
  # @param delimiter {String} structure parts delimiter defaults to '.'
  # @param skipEmpty {Boolean} should skip empty text values, defaults to true
  # @param nodeCallback {Function} custom function to get node value
  # @param useIdIfEmptyName {Boolean} if true value of id attribute of field will be used if name of field is empty
  ###

  form2js = (rootNode, delimiter, skipEmpty, nodeCallback, useIdIfEmptyName, getDisabled) ->
    getDisabled = if getDisabled then true else false
    if typeof skipEmpty == 'undefined' or skipEmpty == null
      skipEmpty = true
    if typeof delimiter == 'undefined' or delimiter == null
      delimiter = '.'
    if arguments.length < 5
      useIdIfEmptyName = false
    rootNode = if typeof rootNode == 'string' then document.getElementById(rootNode) else rootNode
    formValues = []
    currNode = undefined
    i = 0

    ### If rootNode is array - combine values ###

    if rootNode.constructor == Array or typeof NodeList != 'undefined' and rootNode.constructor == NodeList
      while currNode = rootNode[i++]
        formValues = formValues.concat(getFormValues(currNode, nodeCallback, useIdIfEmptyName, getDisabled))
    else
      formValues = getFormValues(rootNode, nodeCallback, useIdIfEmptyName, getDisabled)
    processNameValues formValues, skipEmpty, delimiter

  ###*
  # Processes collection of { name: 'name', value: 'value' } objects.
  # @param nameValues
  # @param skipEmpty if true skips elements with value == '' or value == null
  # @param delimiter
  ###

  processNameValues = (nameValues, skipEmpty, delimiter) ->
    result = {}
    arrays = {}
    i = undefined
    j = undefined
    k = undefined
    l = undefined
    value = undefined
    nameParts = undefined
    currResult = undefined
    arrNameFull = undefined
    arrName = undefined
    arrIdx = undefined
    namePart = undefined
    name = undefined
    _nameParts = undefined
    i = 0
    while i < nameValues.length
      value = nameValues[i].value
      if skipEmpty and (value == '' or value == null)
        i++
        continue
      name = nameValues[i].name
      _nameParts = name.split(delimiter)
      nameParts = []
      currResult = result
      arrNameFull = ''
      j = 0
      while j < _nameParts.length
        namePart = _nameParts[j].split('][')
        if namePart.length > 1
          k = 0
          while k < namePart.length
            if k == 0
              namePart[k] = namePart[k] + ']'
            else if k == namePart.length - 1
              namePart[k] = '[' + namePart[k]
            else
              namePart[k] = '[' + namePart[k] + ']'
            arrIdx = namePart[k].match(/([a-z_]+)?\[([a-z_][a-z0-9_]+?)\]/i)
            if arrIdx
              l = 1
              while l < arrIdx.length
                if arrIdx[l]
                  nameParts.push arrIdx[l]
                l++
            else
              nameParts.push namePart[k]
            k++
        else
          nameParts = nameParts.concat(namePart)
        j++
      j = 0
      while j < nameParts.length
        namePart = nameParts[j]
        if namePart.indexOf('[]') > -1 and j == nameParts.length - 1
          arrName = namePart.substr(0, namePart.indexOf('['))
          arrNameFull += arrName
          if !currResult[arrName]
            currResult[arrName] = []
          currResult[arrName].push value
        else if namePart.indexOf('[') > -1
          arrName = namePart.substr(0, namePart.indexOf('['))
          arrIdx = namePart.replace(/(^([a-z_]+)?\[)|(\]$)/gi, '')

          ### Unique array name ###

          arrNameFull += '_' + arrName + '_' + arrIdx

          ###
          # Because arrIdx in field name can be not zero-based and step can be
          # other than 1, we can't use them in target array directly.
          # Instead we're making a hash where key is arrIdx and value is a reference to
          # added array element
          ###

          if !arrays[arrNameFull]
            arrays[arrNameFull] = {}
          if arrName != '' and !currResult[arrName]
            currResult[arrName] = []
          if j == nameParts.length - 1
            if arrName == ''
              currResult.push value
              arrays[arrNameFull][arrIdx] = currResult[currResult.length - 1]
            else
              currResult[arrName].push value
              arrays[arrNameFull][arrIdx] = currResult[arrName][currResult[arrName].length - 1]
          else
            if !arrays[arrNameFull][arrIdx]
              if /^[0-9a-z_]+\[?/i.test(nameParts[j + 1])
                currResult[arrName].push {}
              else
                currResult[arrName].push []
              arrays[arrNameFull][arrIdx] = currResult[arrName][currResult[arrName].length - 1]
          currResult = arrays[arrNameFull][arrIdx]
        else
          arrNameFull += namePart
          if j < nameParts.length - 1
            if !currResult[namePart]
              currResult[namePart] = {}
            currResult = currResult[namePart]
          else
            currResult[namePart] = value
        j++
      i++
    result

  getFormValues = (rootNode, nodeCallback, useIdIfEmptyName, getDisabled) ->
    result = extractNodeValues(rootNode, nodeCallback, useIdIfEmptyName, getDisabled)
    if result.length > 0 then result else getSubFormValues(rootNode, nodeCallback, useIdIfEmptyName, getDisabled)

  getSubFormValues = (rootNode, nodeCallback, useIdIfEmptyName, getDisabled) ->
    result = []
    currentNode = rootNode.firstChild
    while currentNode
      result = result.concat(extractNodeValues(currentNode, nodeCallback, useIdIfEmptyName, getDisabled))
      currentNode = currentNode.nextSibling
    result

  extractNodeValues = (node, nodeCallback, useIdIfEmptyName, getDisabled) ->
    if node.disabled and !getDisabled
      return []
    callbackResult = undefined
    fieldValue = undefined
    result = undefined
    fieldName = getFieldName(node, useIdIfEmptyName)
    callbackResult = nodeCallback and nodeCallback(node)
    if callbackResult and callbackResult.name
      result = [ callbackResult ]
    else if fieldName != '' and node.nodeName.match(/INPUT|TEXTAREA/i)
      fieldValue = getFieldValue(node, getDisabled)
      if null == fieldValue
        result = []
      else
        result = [ {
          name: fieldName
          value: fieldValue
        } ]
    else if fieldName != '' and node.nodeName.match(/SELECT/i)
      fieldValue = getFieldValue(node, getDisabled)
      result = [ {
        name: fieldName.replace(/\[\]$/, '')
        value: fieldValue
      } ]
    else
      result = getSubFormValues(node, nodeCallback, useIdIfEmptyName, getDisabled)
    result

  getFieldName = (node, useIdIfEmptyName) ->
    if node.name and node.name != ''
      node.name
    else if useIdIfEmptyName and node.id and node.id != ''
      node.id
    else
      ''

  getFieldValue = (fieldNode, getDisabled) ->
    if fieldNode.disabled and !getDisabled
      return null
    switch fieldNode.nodeName
      when 'INPUT', 'TEXTAREA'
        switch fieldNode.type.toLowerCase()
          when 'radio'
            if fieldNode.checked and fieldNode.value == 'false'
              return false
          when 'checkbox'
            if fieldNode.checked and fieldNode.value == 'true'
              return true
            if !fieldNode.checked and fieldNode.value == 'true'
              return false
            if fieldNode.checked
              return fieldNode.value
          when 'button', 'reset', 'submit', 'image'
            return ''
          else
            return fieldNode.value
            break
      when 'SELECT'
        return getSelectedOptionValue(fieldNode)
      else
        break
    null

  getSelectedOptionValue = (selectNode) ->
    multiple = selectNode.multiple
    result = []
    options = undefined
    i = undefined
    l = undefined
    if !multiple
      return selectNode.value
    options = selectNode.getElementsByTagName('option')
    i = 0
    l = options.length
    while i < l
      if options[i].selected
        result.push options[i].value
      i++
    result

  'use strict'
  form2js

# ---
# generated by js2coffee 2.0.3