
import os

def create_file(path):
    """Create an empty file at the specified path."""
    with open(path, 'w') as f:
        pass

def create_directory_structure(base_path):
    """Create the specified directory structure and files."""
    # Define the structure as a dictionary
    structure = {
        'lib': {
            'main.dart': None,
            'app': {
                'app.dart': None,
                'router': {
                    'app_router.dart': None,
                    'route_names.dart': None
                },
                'theme': {
                    'app_theme.dart': None,
                    'colors.dart': None,
                    'text_styles.dart': None
                }
            },
            'core': {
                'constants': {
                    'api_constants.dart': None,
                    'app_constants.dart': None,
                    'storage_constants.dart': None
                },
                'error': {
                    'exceptions.dart': None,
                    'failures.dart': None,
                    'error_handler.dart': None
                },
                'network': {
                    'dio_client.dart': None,
                    'network_info.dart': None,
                    'interceptors': {
                        'auth_interceptor.dart': None,
                        'logging_interceptor.dart': None,
                        'error_interceptor.dart': None
                    }
                },
                'storage': {
                    'secure_storage.dart': None,
                    'shared_preferences_helper.dart': None,
                    'cache_manager.dart': None
                },
                'utils': {
                    'validators.dart': None,
                    'formatters.dart': None,
                    'extensions.dart': None,
                    'helpers.dart': None,
                    'logger.dart': None
                },
                'widgets': {
                    'custom_button.dart': None,
                    'custom_text_field.dart': None,
                    'loading_widget.dart': None,
                    'error_widget.dart': None,
                    'custom_app_bar.dart': None
                }
            },
            'features': {
                'auth': {
                    'data': {
                        'datasources': {
                            'auth_local_datasource.dart': None,
                            'auth_remote_datasource.dart': None
                        },
                        'models': {
                            'auth_request_model.dart': None,
                            'auth_response_model.dart': None,
                            'user_model.dart': None,
                            'session_model.dart': None
                        },
                        'repositories': {
                            'auth_repository_impl.dart': None
                        }
                    },
                    'domain': {
                        'entities': {
                            'user_entity.dart': None,
                            'auth_entity.dart': None
                        },
                        'repositories': {
                            'auth_repository.dart': None
                        },
                        'usecases': {
                            'login_usecase.dart': None,
                            'register_usecase.dart': None,
                            'logout_usecase.dart': None,
                            'refresh_token_usecase.dart': None,
                            'forgot_password_usecase.dart': None,
                            'verify_email_usecase.dart': None
                        }
                    },
                    'presentation': {
                        'bloc': {
                            'auth_bloc.dart': None,
                            'auth_event.dart': None,
                            'auth_state.dart': None
                        },
                        'pages': {
                            'login_page.dart': None,
                            'register_page.dart': None,
                            'forgot_password_page.dart': None,
                            'reset_password_page.dart': None,
                            'verify_email_page.dart': None,
                            'splash_page.dart': None
                        },
                        'widgets': {
                            'login_form.dart': None,
                            'register_form.dart': None,
                            'password_field.dart': None,
                            'social_login_buttons.dart': None
                        }
                    }
                }
            },
            'shared': {
                'models': {
                    'api_response.dart': None,
                    'pagination_model.dart': None,
                    'media_model.dart': None
                },
                'widgets': {
                    'bottom_navigation.dart': None,
                    'custom_drawer.dart': None,
                    'media_picker.dart': None
                }
            }
        }
    }

    def create_structure(current_path, items):
        """Recursively create directories and files."""
        for name, content in items.items():
            new_path = os.path.join(current_path, name)
            if content is None:  # It's a file
                create_file(new_path)
                AppLogger.debug(f"Created file: {new_path}")
            else:  # It's a directory
                os.makedirs(new_path, exist_ok=True)
                AppLogger.debug(f"Created directory: {new_path}")
                create_structure(new_path, content)

    # Start creating the structure
    create_structure(base_path, structure)

if __name__ == "__main__":
    # Set the base path to current directory
    base_path = os.getcwd()
    create_directory_structure(base_path)
    AppLogger.debug("Directory structure created successfully!")