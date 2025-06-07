                button.ButtonComponent(
                  value: _isLoading ? 'Registering...' : 'Sign Up',
                  onClick: _signUp,
                  isEnabled: !_isLoading && _isIdAvailable && _isChecked && _fullNameController.text.isNotEmpty && _idController.text.isNotEmpty && _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty,
                ),
                const SizedBox(height: 15), 