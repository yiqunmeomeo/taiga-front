###
# Copyright (C) 2014-2015 Taiga Agile LLC <taiga@taiga.io>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# File: attchments.controller.coffee
###

class AttachmentsController
    @.$inject = [
        "tgAttachmentsService"
    ]

    constructor: (@attachmentsService) ->
        @.maxFileSize = @attachmentsService.maxFileSize
        @.maxFileSizeFormated = @attachmentsService.maxFileSizeFormated

    addAttachment: (file) ->
        attachment = Immutable.fromJS({
            file: file,
            name: file.name,
            size: file.size
        })

        if @attachmentsService.validate(file)
            @.attachments = @.attachments.push(attachment)

            if @.onAdd
                @.onAdd({attachment: attachment})

    addAttachments: (files) ->
        _.forEach files, @.addAttachment.bind(this)

    deleteAttachment: (toDeleteAttachment) ->
        @.attachments = @.attachments.filter (attachment) -> attachment != toDeleteAttachment

        if @.onDelete
            @.onDelete({attachment: toDeleteAttachment})

angular.module("taigaComponents").controller("Attachments", AttachmentsController)


class AttachmentsController2
    @.$inject = [
        "tgAttachmentsService",
        "$tgResources"
    ]

    constructor: (@attachmentsService, @rs) ->
        @.deprecatedsVisible = false
        @.maxFileSize = @attachmentsService.maxFileSize
        @.maxFileSizeFormated = @attachmentsService.maxFileSizeFormated

    loadAttachments: ->
        urlname = "attachments/#{@.type}"

        # move to new resources
        return @rs.attachments.list(urlname, @.objId, @.projectId).then (attachments) =>
            attachments = _.sortBy(attachments, "order")
            attachments = _.map attachments, (attachment) -> attachment._attrs

            @.attachments = Immutable.fromJS(attachments)

            return attachments

    generate: () ->
        @.deprecatedsCount = @.attachments.count (it) -> it.get('is_deprecated')

    toggleDeprecatedsVisible: () ->
        @.deprecatedsVisible = !@.deprecatedsVisible
        @.generate()

    addAttachment: (file) ->
        if @attachmentsService.validate(file)
            promise = @attachmentsService.upload(file, @.objId, @.projectId, @.type)

            promise.then (attachment) =>
                attachment = Immutable.fromJS(attachment._attrs)
                @.attachments = @.attachments.push(attachment)

    addAttachments: (files) ->
        _.forEach files, @.addAttachment.bind(this)

    deleteAttachment: (toDeleteAttachment) ->
        @.attachments = @.attachments.filter (attachment) -> attachment != toDeleteAttachment

        if @.onDelete
            @.onDelete({attachment: toDeleteAttachment})

    reorderAttachment: (attachment, newIndex) ->
        oldIndex = @.attachments.findIndex (it) -> it == attachment
        return if oldIndex == newIndex

        @.attachments = @.attachments.remove(oldIndex)
        @.attachments = @.attachments.splice(newIndex, 0, attachment)

        @.attachments = @.attachments.map (x, i) -> x.set('order', i + 1)

    updateAttachment: (toUpdateAttachment) ->
        index = @.attachments.findIndex (attachment) ->
            return attachment.get('id') == toUpdateAttachment.get('id')

        @.attachments = @.attachments.update index, () -> toUpdateAttachment

angular.module("taigaComponents").controller("Attachments2", AttachmentsController2)
