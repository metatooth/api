import {HTTP} from './http-common'

const RESOURCE_NAME = '/tasks'

export default {
    download_all: function (token, from = null, to = null) {
        let resource = `${RESOURCE_NAME}?format=html`
        
        if (from && to) {
            resource = resource + `&from=${from}&to=${to}`
        } else if (from) {
            resource = resource + `&from=${from}`
        } else if (to) {
            resource = resource + `&to=${to}`
        }

        return HTTP.get(resource, { headers: { 'Authorization': `Bearer ${token}` } })
    },

    get_all: function (token, from = null, to = null) {
        let resource = `${RESOURCE_NAME}`
        
        if (from && to) {
            resource = resource + `?from=${from}&to=${to}`
        } else if (from) {
            resource = resource + `?from=${from}`
        } else if (to) {
            resource = resource + `?to=${to}`
        }

        return HTTP.get(resource, { headers: { 'Authorization': `Bearer ${token}` } })
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