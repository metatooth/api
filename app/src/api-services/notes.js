import {HTTP} from './http-common'

const TASKS = '/tasks/'

const NOTES = '/notes'

export default {
    get: function (task_id, note_id, token) {
        return HTTP.get(`${TASKS}${task_id}${NOTES}/${note_id}`, { headers: { 'Authorization': `Bearer ${token}` } })
    },

    get_all: function (task_id, token) {
        return HTTP.get(`${TASKS}${task_id}${NOTES}`, { headers: { 'Authorization': `Bearer ${token}` } })
    },

    create: function (task_id, data, token) {
        return HTTP.post(`${TASKS}${task_id}${NOTES}`, data, { headers: { 'Authorization': `Bearer ${token}` } })
    },

    update: function (task_id, note_id, data, token) {
        return HTTP.put(`${TASKS}${task_id}${NOTES}/${note_id}`, data, { headers: { 'Authorization': `Bearer ${token}` } })
    },

    destroy: function (task_id, note_id, token) {
        return HTTP.delete(`${TASKS}${task_id}${NOTES}/${note_id}`, { headers: { 'Authorization': `Bearer ${token}` } })
    },
}