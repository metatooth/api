import {HTTP} from './http-common'

const RESOURCE_NAME = '/users'

export default {
    get_all: function (token) {
        return HTTP.get(`${RESOURCE_NAME}`, { headers: { 'Authorization': `Bearer ${token}` } })
    },

    get: function (id, token) {
        return HTTP.get(`${RESOURCE_NAME}/${id}`, { headers: { 'Authorization': `Bearer ${token}` } })
    },

    create: function (data, token) {
        return HTTP.post(`${RESOURCE_NAME}`, data, { headers: { 'Authorization': `Bearer ${token}` } })
    },

    update: function (id, data, token) {
        return HTTP.put(`${RESOURCE_NAME}/${id}`, data, { headers: { 'Authorization': `Bearer ${token}` } })
    },

    destroy: function (id, token) {
        return HTTP.delete(`${RESOURCE_NAME}/${id}`, { headers: { 'Authorization': `Bearer ${token}` } })
    },
}