import {HTTP} from './http-common'

const RESOURCE_NAME = '/meals'

export default {
    get_all: function (token) {
        return HTTP.get(`${RESOURCE_NAME}?token=${token}`)
    },

    get: function (id, token) {
        return HTTP.get(`${RESOURCE_NAME}/${id}`)
    },

    create: function (data, token) {
        return HTTP.post(`${RESOURCE_NAME}?token=${token}`, data)
    },

    update: function (id, data, token) {
        return HTTP.put(`${RESOURCE_NAME}/${id}?token=${token}`, data)
    },

    destroy: function (id, token) {
        return HTTP.delete(`${RESOURCE_NAME}/${id}?token=${token}`)
    },
}