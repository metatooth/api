import {HTTP} from './http-common'

export default {
    signin: function (data) {
        return HTTP.post('/access_tokens', data)
    },

    signup: function (data) {
        return HTTP.post('/users', data)
    },

    signout: function () {
        return HTTP.delete('/access_tokens')
    },
}
