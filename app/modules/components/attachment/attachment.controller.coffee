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
# File: attchment.controller.spec.coffee
###

class AttachmentController
    @.$inject = [
        'tgAttachmentsService',
        '$translate'
    ]

    editable: false

    constructor: (@attachmentsService, @translate) ->
        @.form = {}
        @.form.description = @.attachment.get('description')
        @.form.is_deprecated = @.attachment.get('is_deprecated')

        @.title = @translate.instant("ATTACHMENT.TITLE", {
                            fileName: @.attachment.get('name'),
                            date: moment(@.attachment.get('created_date')).format(@translate.instant("ATTACHMENT.DATE"))
                        })

    editMode: (mode) ->
        @.editable = mode

    delete: () ->
        @.onDelete({attachment: @.attachment}) if @.onDelete

    save: () ->
        @.editable = false

        @.attachment = @.attachment.set('description', @.form.description)
        @.attachment = @.attachment.set('is_deprecated', @.form.is_deprecated)

        @.onUpdate({attachment: @.attachment}) if @.onUpdate

angular.module('taigaComponents').controller('Attachment', AttachmentController)
