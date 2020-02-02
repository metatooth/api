<template>
  <div
    id="app"
    class="container"
  >
    <main-nav
      :active-user="active_user"
      :token="access_token"
      :on-settings="do_settings"
      :on-signout="do_signout"
      :on-users="show_users"
      :on-tasks="show_tasks"
    />
    <sign-up
      v-if="signup_visible"
      :on-close="show_signin"
    />
    <sign-in
      v-if="signin_visible"
      :on-signin="do_signin"
      :on-signup="show_signup"
    />
    <tasks
      v-if="tasks_visible"
      :tasks="tasks"
      :preferred-working-seconds-per-day="parseInt(active_user.preferred_working_seconds_per_day)"
      :token="access_token"
      :on-edit="show_edittask"
    />
    <edit-task
      v-if="edittask_visible"
      :record="edit_task"
      :cache="cache_task"
      :token="access_token"
      :on-close="show_tasks"
    />
    <users
      v-if="users_visible"
      :current="active_user"
      :users="users"
      :token="access_token"
      :on-edit="show_edituser"
    />
    <edit-user
      v-if="edituser_visible"
      :record="edit_user"
      :cache="cache_user"
      :token="access_token"
      :on-close="show_users"
    />
    <settings
      v-if="settings_visible"
      :record="active_user"
      :cache="cache_user"
      :token="access_token"
      :on-close="show_tasks"
    />
    <footer class="footer">
      Questions? Contact <a href="mailto:terry@metatooth.com">terry@metatooth.com</a>
    </footer>
  </div>
</template>

<script>
import TasksService from './api-services/tasks'
import UsersService from './api-services/users'

import EditTask from './components/EditTask.vue'
import EditUser from './components/EditUser.vue'
import MainNav from './components/MainNav.vue'
import Tasks from './components/Tasks.vue'
import Settings from './components/Settings.vue'
import SignUp from './components/SignUp.vue'
import SignIn from './components/SignIn.vue'
import Users from './components/Users.vue'

export default {
  name: 'App',
  components: {
    EditTask,
    EditUser,
    MainNav,
    Tasks,
    Settings,
    SignUp,
    SignIn,
    Users
  },
  data () {
    return {
      access_token: '',
      active_user: null,
      cache_task: null,
      cache_user: null,
      edit_task: null,
      edit_user: null,
      edittask_visible: false,
      edituser_visible: false,
      tasks: [],
      settings_visible: false,
      signin_visible: true,
      signup_visible: false,
      tasks_visible: false,
      users: [],
      users_visible: false
    }
  },
  methods: {
    do_cancel_signup: function () {
      this.show_signin()
    },
    do_settings: function () {
      this.show_settings()
    },
    do_signin: function(token) {
      this.access_token = token
      
      TasksService.get_all(this.access_token)
        .then(response => {
          this.tasks = response.data
        }).catch(error => {
          console.log(error)
        })

      UsersService.get_all(this.access_token).then(response => {
        if (response.data.length == 1) {
          this.users = []
          // :TRICKY: 20190604 Terry: This single entry _should_ match the authenticated user. 
          this.active_user = response.data[0]
        } else {
          this.users = response.data
          for (let i = 0; i < response.data.length; ++i) {
            // :NOTE: 20190605 Terry: This is why the access token is exposed in the users API response.
            if (response.data[i].access_token == this.access_token) {
              this.active_user = response.data[i]
            }
          }
        }
        this.show_tasks()
      }).catch(error => {
        console.log(error)
      })
    },
    do_signout: function() {
      this.access_token = ''
      this.show_signin()
    },
    show_edittask: function (task) {
      this.edit_task = task
      
      this.cache_task = {}
      this.cache_task['id'] = task['id']
      this.cache_task['completed_on'] = task['completed_on']
      this.cache_task['description'] = task['description']
      this.cache_task['duration'] = task['duration']

      this.settings_visible = false
      this.signin_visible = false
      this.signup_visible = false
      this.tasks_visible = false
      this.edittask_visible = true
      this.users_visible = false
      this.edituser_visible = false
    },
    show_edituser: function (user) {
      this.edit_user = user
      
      this.cache_user = {}
      this.cache_user['id'] = user['id']
      this.cache_user['username'] = user['username']
      this.cache_user['preferred_working_seconds_per_day'] = user['preferred_working_seconds_per_day']
      this.cache_user['type'] = user['type']

      this.settings_visible = false
      this.signin_visible = false
      this.signup_visible = false
      this.tasks_visible = false
      this.edittask_visible = false
      this.users_visible = false
      this.edituser_visible = true
    },
    show_settings: function () {
      this.cache_user = {}
      this.cache_user['preferred_working_seconds_per_day'] = this.active_user['preferred_working_seconds_per_day']

      this.settings_visible = true
      this.signin_visible = false
      this.signup_visible = false
      this.tasks_visible = false
      this.edittask_visible = false
      this.users_visible = false
      this.edituser_visible = false
    },
    show_signin: function () {
      this.settings_visible = false
      this.signin_visible = true
      this.signup_visible = false
      this.tasks_visible = false
      this.edittask_visible = false
      this.users_visible = false
      this.edituser_visible = false
    },
    show_signup: function () {
      this.signin_visible = false
      this.settings_visible = false
      this.signup_visible = true
      this.tasks_visible = false
      this.edittask_visible = false
      this.users_visible = false
      this.edituser_visible = false
    },
    show_tasks: function () {
      this.edit_task = null
      this.settings_visible = false
      this.signin_visible = false
      this.signup_visible = false
      this.tasks_visible = true
      this.edittask_visible = false
      this.users_visible = false
      this.edituser_visible = false
    },
    show_users: function () {
      this.edit_user = null
      this.settings_visible = false
      this.signin_visible = false
      this.signup_visible = false
      this.tasks_visible = false
      this.edittask_visible = false
      this.users_visible = true
      this.edituser_visible = false
    }

  }
}
</script>

<style lang="scss">
@charset "utf-8";
@import "~bulma/bulma";

[v-cloak] { display: none; }

.section {
  padding-top: 12px;
}

</style>
