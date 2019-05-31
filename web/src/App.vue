<template>
  <div id="app">
    <section v-show="signup_visible" ref="signup" class="signup">
      <form>
        <div class="control">
          <input type="text" v-model="username" placeholder="Username" />
        </div>
        <div class="control">
          <input type="password" v-model="password" placeholder="Password" />
        </div>
        <div class="control">
          <input type="password" v-model="confirm_password" placeholder="Confirm password" />
        </div>
        <div class="control">
          <button type="submit" lass="button" @click="signup">Sign Up</button>
        </div>
        <div class="errors">
          {{ signup_error }}
        </div>
        <div><a href="#" @click="show_signin">Cancel</a></div>
      </form>
    </section>
    <section v-show="signin_visible" ref="signin" class="signin">
      <form>
        <div class="control">
          <input type="text" v-model="username" placeholder="Username" />
        </div>
        <div class="control">
          <input type="password" v-model="password" placeholder="Password" />
        </div>
        <div class="control">
          <button type="submit" class="button" @click="signin">Sign In</button>
        </div>
        <div class="errors">
          {{ signin_error }}
        </div>
        <div>Or <a href="#" @click="show_signup">Sign Up</a></div>
      </form>
    </section>
    <section v-show="tracker_visible" class="tracker">
      <header class="header">
        <h1>Calorie Tracker</h1>
        <input v-model="text" placeholder="Description" />
        <input v-model="calories" placeholder="Calories" />
        <button class="button" :disabled=!isComplete @click="save">Save</button>
      </header>
      <section class="main" v-show="meals.length">
        <ul class="meal-list">
          <li v-for="meal in meals" class="meal" :key="meal.id" :class = "{ highlight: meal.overlimit }">
            <div class="view">
              <label @dblclick="edit(meal, 'taken')">{{ meal.taken }}</label>
              <label @dblclick="edit(meal, 'text')">{{ meal.text }}</label>
              <label @dblclick="edit(meal, 'calories')">{{ meal.calories }}</label>
              <button class="destroy" @click="remove(meal)"></button>
            </div>
            <input class="edit" type="text"
              v-model="meal.calories"
              v-meal-focus="meal === edited_meal"   
              @blur="done(meal)"
              @keyup.enter="done(meal)"
              @keyup.esc="cancel(meal)"/>       
          </li>
        </ul>    
      </section>
      <footer class="footer">
      </footer>
    </section>
  </div>
</template>

<script>
import AuthService from './api-services/auth'
import MealsService from './api-services/meals'

export default {
  name: 'app',
  data () {
    return {
      calories: '',
      confirm_password: '',
      edited_meal: null,
      meals: [],
      password: '',
      signin_error: '',
      signin_visible: true,
      signup_error: '',
      signup_visible: false,
      text: '',
      tracker_visible: false,
      username: '',
      users: []
    }
  },
  computed: {
    isComplete: function () {
      return (this.$data.text.length != 0 && this.$data.calories.length != 0)
    }
  },
  methods: {
    clear_credentials: function () {
      this.$data.username = ''
      this.$data.password = ''
      this.$data.confirm_password = ''
    },
    clear_meal: function () {
      this.$data.text = ''
      this.$data.calories = ''
    },
    edit: function(meal, attr) {
    
    },
    fetch_meals: function() {
      const scope = this
      MealsService.get_all(scope.$data.access_token).then(response => {
        scope.$data.meals = []
        for (let i = 0; i < response.data.length; ++i) {
          scope.$data.meals.push(response.data[i])
        }
      }).catch(e => {
        console.log(e)
      })
    },
    remove: function (meal) {
      const scope = this
      MealsService.destroy(meal.id, this.$data.access_token)
        .then(response => {
          console.log(response.data)
          scope.fetch_meals()
        }).catch(e => {
          console.log(e)
        })
    },
    save: function () {
      console.log(this.$data.access_token)
      const scope = this
      MealsService.create({ taken: new Date(), text: this.$data.text, calories: this.$data.calories },
        scope.$data.access_token)
      .then(response => {
        console.log(response)
        scope.clear_meal()
        scope.fetch_meals()
      }).catch(e => {
        console.log(e)
      })
    },
    show_signin: function () {
      this.$data.signin_visible = true
      this.$data.signup_visible = false
      this.$data.tracker_visible = false
      this.clear_credentials()
    },
    show_signup: function () {
      this.$data.signin_visible = false
      this.$data.signup_visible = true
      this.$data.tracker_visible = false
      this.clear_credentials()
    },
    show_tracker: function () {
      this.$data.signin_visible = false
      this.$data.signup_visible = false
      this.$data.tracker_visible = true
    },    
    signup: function () {
      const scope = this
      scope.$data.signup_error = ''
      AuthService.signup({ username: scope.$data.username, password: scope.$data.password })
      .then(response => {
        console.log(response.data)
        scope.show_signin()
      }).catch(e => {
        scope.$data.signup_error = e
        console.log(e)
      })
    },
    signin: function () {
      const scope = this
      scope.$data.signin_error = ''
      AuthService.signin({ username: this.$data.username, password: this.$data.password })
      .then(response => {
        console.log(response.data)
        scope.$data.access_token = response.data
        scope.show_tracker()
        scope.fetch_meals()
      }).catch(e => {
        scope.$data.signin_error = e
        console.log(e)
      })
    },
    signout: function () {

    }
  },
  directives: {
    'meal-focus': function (el, binding) {
      if (binding.value) {
        el.focus()
      }
    }
  }

}
</script>

<style lang="css">
html,
body {
	margin: 0;
	padding: 0;
}

button {
	margin: 0;
	padding: 0;
	border: 0;
	background: none;
	font-size: 100%;
	vertical-align: baseline;
	font-family: inherit;
	font-weight: inherit;
	color: inherit;
	-webkit-appearance: none;
	appearance: none;
	-webkit-font-smoothing: antialiased;
	-moz-osx-font-smoothing: grayscale;
}

body {
	font: 14px 'Helvetica Neue', Helvetica, Arial, sans-serif;
	line-height: 1.4em;
	background: #f5f5f5;
	color: #4d4d4d;
	min-width: 230px;
	max-width: 550px;
	margin: 0 auto;
	-webkit-font-smoothing: antialiased;
	-moz-osx-font-smoothing: grayscale;
	font-weight: 300;
}

:focus {
	outline: 0;
}

.hidden {
	display: none;
}

.app {
	background: #fff;
	margin: 130px 0 40px 0;
	position: relative;
	box-shadow: 0 2px 4px 0 rgba(0, 0, 0, 0.2),
	            0 25px 50px 0 rgba(0, 0, 0, 0.1);
}

.app input::-webkit-input-placeholder {
	font-style: italic;
	font-weight: 300;
	color: #e6e6e6;
}

.app input::-moz-placeholder {
	font-style: italic;
	font-weight: 300;
	color: #e6e6e6;
}

.app input::input-placeholder {
	font-style: italic;
	font-weight: 300;
	color: #e6e6e6;
}

.app h1 {
	position: absolute;
	top: -155px;
	width: 100%;
	font-size: 100px;
	font-weight: 100;
	text-align: center;
	color: rgba(175, 47, 47, 0.15);
	-webkit-text-rendering: optimizeLegibility;
	-moz-text-rendering: optimizeLegibility;
	text-rendering: optimizeLegibility;
}

.new-meal,
.edit {
	position: relative;
	margin: 0;
	width: 100%;
	font-size: 24px;
	font-family: inherit;
	font-weight: inherit;
	line-height: 1.4em;
	border: 0;
	color: inherit;
	padding: 6px;
	border: 1px solid #999;
	box-shadow: inset 0 -1px 5px 0 rgba(0, 0, 0, 0.2);
	box-sizing: border-box;
	-webkit-font-smoothing: antialiased;
	-moz-osx-font-smoothing: grayscale;
}

.new-meal {
	padding: 16px 16px 16px 60px;
	border: none;
	background: rgba(0, 0, 0, 0.003);
	box-shadow: inset 0 -2px 1px rgba(0,0,0,0.03);
}

.main {
	position: relative;
	z-index: 2;
	border-top: 1px solid #e6e6e6;
}

.toggle-all {
	width: 1px;
	height: 1px;
	border: none; /* Mobile Safari */
	opacity: 0;
	position: absolute;
	right: 100%;
	bottom: 100%;
}

.toggle-all + label {
	width: 60px;
	height: 34px;
	font-size: 0;
	position: absolute;
	top: -52px;
	left: -13px;
	-webkit-transform: rotate(90deg);
	transform: rotate(90deg);
}

.toggle-all + label:before {
	content: '❯';
	font-size: 22px;
	color: #e6e6e6;
	padding: 10px 27px 10px 27px;
}

.toggle-all:checked + label:before {
	color: #737373;
}

.meal-list {
	margin: 0;
	padding: 0;
	list-style: none;
}

.meal-list li {
	position: relative;
	font-size: 24px;
	border-bottom: 1px solid #ededed;
}

.meal-list li:last-child {
	border-bottom: none;
}

.meal-list li.editing {
	border-bottom: none;
	padding: 0;
}

.meal-list li.editing .edit {
	display: block;
	width: calc(100% - 43px);
	padding: 12px 16px;
	margin: 0 0 0 43px;
}

.meal-list li.editing .view {
	display: none;
}

.meal-list li .toggle {
	text-align: center;
	width: 40px;
	/* auto, since non-WebKit browsers doesn't support input styling */
	height: auto;
	position: absolute;
	top: 0;
	bottom: 0;
	margin: auto 0;
	border: none; /* Mobile Safari */
	-webkit-appearance: none;
	appearance: none;
}

.meal-list li .toggle {
	opacity: 0;
}

.meal-list li .toggle + label {
	/*
		Firefox requires `#` to be escaped - https://bugzilla.mozilla.org/show_bug.cgi?id=922433
		IE and Edge requires *everything* to be escaped to render, so we do that instead of just the `#` - https://developer.microsoft.com/en-us/microsoft-edge/platform/issues/7157459/
	*/
	background-image: url('data:image/svg+xml;utf8,%3Csvg%20xmlns%3D%22http%3A//www.w3.org/2000/svg%22%20width%3D%2240%22%20height%3D%2240%22%20viewBox%3D%22-10%20-18%20100%20135%22%3E%3Ccircle%20cx%3D%2250%22%20cy%3D%2250%22%20r%3D%2250%22%20fill%3D%22none%22%20stroke%3D%22%23ededed%22%20stroke-width%3D%223%22/%3E%3C/svg%3E');
	background-repeat: no-repeat;
	background-position: center left;
}

.meal-list li .toggle:checked + label {
	background-image: url('data:image/svg+xml;utf8,%3Csvg%20xmlns%3D%22http%3A//www.w3.org/2000/svg%22%20width%3D%2240%22%20height%3D%2240%22%20viewBox%3D%22-10%20-18%20100%20135%22%3E%3Ccircle%20cx%3D%2250%22%20cy%3D%2250%22%20r%3D%2250%22%20fill%3D%22none%22%20stroke%3D%22%23bddad5%22%20stroke-width%3D%223%22/%3E%3Cpath%20fill%3D%22%235dc2af%22%20d%3D%22M72%2025L42%2071%2027%2056l-4%204%2020%2020%2034-52z%22/%3E%3C/svg%3E');
}

.meal-list li label {
	word-break: break-all;
	padding: 15px 15px 15px 60px;
	display: block;
	line-height: 1.2;
	transition: color 0.4s;
}

.meal-list li.completed label {
	color: #d9d9d9;
	text-decoration: line-through;
}

.meal-list li .destroy {
	display: none;
	position: absolute;
	top: 0;
	right: 10px;
	bottom: 0;
	width: 40px;
	height: 40px;
	margin: auto 0;
	font-size: 30px;
	color: #cc9a9a;
	margin-bottom: 11px;
	transition: color 0.2s ease-out;
}

.meal-list li .destroy:hover {
	color: #af5b5e;
}

.meal-list li .destroy:after {
	content: '×';
}

.meal-list li:hover .destroy {
	display: block;
}

.meal-list li .edit {
	display: none;
}

.meal-list li.editing:last-child {
	margin-bottom: -1px;
}

.footer {
	color: #777;
	padding: 10px 15px;
	height: 20px;
	text-align: center;
	border-top: 1px solid #e6e6e6;
}

.footer:before {
	content: '';
	position: absolute;
	right: 0;
	bottom: 0;
	left: 0;
	height: 50px;
	overflow: hidden;
	box-shadow: 0 1px 1px rgba(0, 0, 0, 0.2),
	            0 8px 0 -3px #f6f6f6,
	            0 9px 1px -3px rgba(0, 0, 0, 0.2),
	            0 16px 0 -6px #f6f6f6,
	            0 17px 2px -6px rgba(0, 0, 0, 0.2);
}

.meal-count {
	float: left;
	text-align: left;
}

.meal-count strong {
	font-weight: 300;
}

.filters {
	margin: 0;
	padding: 0;
	list-style: none;
	position: absolute;
	right: 0;
	left: 0;
}

.filters li {
	display: inline;
}

.filters li a {
	color: inherit;
	margin: 3px;
	padding: 3px 7px;
	text-decoration: none;
	border: 1px solid transparent;
	border-radius: 3px;
}

.filters li a:hover {
	border-color: rgba(175, 47, 47, 0.1);
}

.filters li a.selected {
	border-color: rgba(175, 47, 47, 0.2);
}

.clear-completed,
html .clear-completed:active {
	float: right;
	position: relative;
	line-height: 20px;
	text-decoration: none;
	cursor: pointer;
}

.clear-completed:hover {
	text-decoration: underline;
}

.info {
	margin: 65px auto 0;
	color: #bfbfbf;
	font-size: 10px;
	text-shadow: 0 1px 0 rgba(255, 255, 255, 0.5);
	text-align: center;
}

.info p {
	line-height: 1;
}

.info a {
	color: inherit;
	text-decoration: none;
	font-weight: 400;
}

.info a:hover {
	text-decoration: underline;
}

/*
	Hack to remove background from Mobile Safari.
	Can't use it globally since it destroys checkboxes in Firefox
*/
@media screen and (-webkit-min-device-pixel-ratio:0) {
	.toggle-all,
	.meal-list li .toggle {
		background: none;
	}

	.meal-list li .toggle {
		height: 40px;
	}
}

@media (max-width: 430px) {
	.footer {
		height: 50px;
	}

	.filters {
		bottom: 10px;
	}
}
</style>
