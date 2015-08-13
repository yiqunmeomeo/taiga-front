sizeFormat = @.taiga.sizeFormat

class AttachmentsService
    @.$inject = [
        "$tgConfirm",
        "$tgConfig",
        "$translate",
        "$q",
        "$tgResources"
    ]

    constructor: (@confirm, @config, @tranlsate, @q, @rs) ->
        @.maxFileSize = @.getMaxFileSize()

        if @.maxFileSize
            @.maxFileSizeFormated = sizeFormat(@.maxFileSize)

    sizeError: (file) ->
        message = @tranlsate.instant("ATTACHMENT.ERROR_MAX_SIZE_EXCEEDED", {
            fileName: file.name,
            fileSize: sizeFormat(file.size),
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

    delete: (attachment, type) ->
        return @rs.attachments.delete("attachments/" + type, attachment)

    upload: (attachment, obj, type) ->
        promise = @rs.attachments.create("attachments/" + type, obj.project, obj.id, attachment)

        promise = promise.then null, (data) =>
            if data.status == 413
                @.sizeError(attachment)

                message = @translate.instant("ATTACHMENT.ERROR_UPLOAD_ATTACHMENT", {
                            fileName: attachment.name, errorMessage: data.data._error_message})

                @confirm.notify("error", message)

                return @q.reject(data)

            return promise

    uploadUSAttachment: (attachment, obj) ->
        return @.upload(attachment, obj, 'us')

angular.module("taigaCommon").service("tgAttachmentsService", AttachmentsService)
