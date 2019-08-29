import {HTTP} from './http-common'

export default {
    signin: function (data) {
        return HTTP.post('/signin', data)
    },

    signup: function (data) {
        return HTTP.post('/signup', data)
    },

    signout: function () {
        return HTTP.get('/signout')
    },
}