sizeFormat = @.taiga.sizeFormat

class AttachmentsService
    @.$inject = [
        "$tgConfirm",
        "$tgConfig",
        "$translate",
        "$q",
        "tgResources"
    ]

    constructor: (@confirm, @config, @translate, @q, @rs) ->
        @.maxFileSize = @.getMaxFileSize()

        if @.maxFileSize
            @.maxFileSizeFormated = sizeFormat(@.maxFileSize)

    sizeError: (file) ->
        message = @translate.instant("ATTACHMENT.ERROR_MAX_SIZE_EXCEEDED", {
            fileName: file.ge('name'),
            fileSize: sizeFormat(file.get('size')),
            maxFileSize: @.maxFileSizeFormated
        })

        @confirm.notify("error", message)

    validate: (file) ->
        if @.maxFileSize && file.size > @.maxFileSize
            @.sizeError(file)

            return false

        return true

    getMaxFileSize: () ->
        return @config.get("maxUploadFileSize", null)

    list: (type, objId, projectId) ->
        return @rs.attachments.list(type, objId, projectId).then (attachments) =>
            return attachments.sortBy (attachment) => attachment.get('order')

    delete: (attachment, type) ->
        return @rs.attachments.delete(type, attachment.get('id'))

    upload: (file, objId, projectId, type) ->
        promise = @rs.attachments.create(type, projectId, objId, file)

        promise.then null, (data) =>
            if data.status == 413
                @.sizeError(file)

                message = @translate.instant("ATTACHMENT.ERROR_UPLOAD_ATTACHMENT", {
                            fileName: file.get('name'), errorMessage: data.data._error_message})

                @confirm.notify("error", message)

                return @q.reject(data)

        return promise

    patch: (id, type, patch) ->
        return @rs.attachments.patch(type, id, patch)

angular.module("taigaCommon").service("tgAttachmentsService", AttachmentsService)
