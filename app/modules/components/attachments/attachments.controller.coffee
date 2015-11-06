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
        "tgAttachmentsService",
        "$rootScope"
    ]

    constructor: (@attachmentsService, @rootScope) ->
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
        "$rootScope"
    ]

    constructor: (@attachmentsService, @rootScope) ->
        @.deprecatedsVisible = false
        @.maxFileSize = @attachmentsService.maxFileSize
        @.maxFileSizeFormated = @attachmentsService.maxFileSizeFormated
        @.uploadingAttachments = []

    loadAttachments: ->
        @attachmentsService.list(@.type, @.objId, @.projectId).then (files) =>
            @.attachments = files.map (file) ->
                attachment = Immutable.Map()

                return attachment.merge({
                    editable: false,
                    file: file
                })

    generate: () ->
        @.deprecatedsCount = @.attachments.count (it) -> it.get('is_deprecated')

    toggleDeprecatedsVisible: () ->
        @.deprecatedsVisible = !@.deprecatedsVisible
        @.generate()

    addAttachment: (file) ->
        if @attachmentsService.validate(file)
            @.uploadingAttachments.push(file)

            promise = @attachmentsService.upload(file, @.objId, @.projectId, @.type)

            promise.then (file) =>
                @.uploadingAttachments = @.uploadingAttachments.filter (uploading) ->
                    return uploading.name != file.get('name')

                attachment = Immutable.Map()

                attachment = attachment.set('file', file)
                attachment = attachment.set('editable', true)

                @.attachments = @.attachments.push(attachment)

                @rootScope.$broadcast("attachment:create")

    addAttachments: (files) ->
        _.forEach files, @.addAttachment.bind(this)

    deleteAttachment: (toDeleteAttachment) ->
        @attachmentsService.delete(@.type, toDeleteAttachment.get('id')).then () ->
            @.attachments = @.attachments.filter (attachment) -> attachment != toDeleteAttachment

    reorderAttachment: (attachment, newIndex) ->
        oldIndex = @.attachments.findIndex (it) -> it == attachment
        return if oldIndex == newIndex

        @.attachments = @.attachments.remove(oldIndex)
        @.attachments = @.attachments.splice(newIndex, 0, attachment)

        @.attachments = @.attachments.map (x, i) -> x.set('order', i + 1)

    # updateAttachment: (toUpdateAttachment) ->
    #     index = @.attachments.findIndex (attachment) ->
    #         return attachment.get('id') == toUpdateAttachment.get('id')

    #     @.attachments = @.attachments.update index, () -> toUpdateAttachment

    updateAttachment: (toUpdateAttachment) ->
        index = @.attachments.findIndex (attachment) ->
            return attachment.get('id') == toUpdateAttachment.get('id')

        oldAttachment = @.attachments.get(index)

        patch = taiga.patch(oldAttachment.get('file'), toUpdateAttachment.get('file'))

        onSuccess = =>
            @.updateCounters()
            @rootScope.$broadcast("attachment:edit")

        onError = (response) =>
            $scope.$emit("attachments:size-error") if response.status == 413
            @confirm.notify("error")
            return @q.reject()

        return @attachmentsService.patch(toUpdateAttachment.getIn(['file', 'id']), @.type, patch)
            .then(onSuccess, onError)

angular.module("taigaComponents").controller("Attachments2", AttachmentsController2)
