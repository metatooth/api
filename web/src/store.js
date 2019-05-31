import Vue from 'vue'  
import Vuex from 'vuex'
import Axios from 'axios'

Axios.defaults.baseURL = process.env.API_ENDPOINT

Vue.use(Vuex)

const state = {
    access_token: '',
    user: null,
    meals: [],
    users: []  
}

const actions = {  
  // asynchronous operations
}

const mutations = {  
  // isolated data mutations
}

const getters = {  
  // reusable data accessors
}

const store = new Vuex.Store({  
  state,
  actions,
  mutations,
  getters
})

export default store  