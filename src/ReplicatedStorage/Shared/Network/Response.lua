--!strict

export type Response<T> = {
    requestId: string,
    success: boolean,
    code: string,
    message: string,
    data: T?,
}

local Response = {}

function Response.success<T>(requestId: string, data: T?): Response<T>
    return { requestId = requestId, success = true, code = "OK", message = "", data = data }
end

function Response.failure(requestId: string, code: string, message: string): Response<never>
    return { requestId = requestId, success = false, code = code, message = message, data = nil }
end

return table.freeze(Response)
