from jinja2_base64_filters import jinja2_base64_filters
from jinja2 import Environment

def j2_environment_params():
    """ Extra parameters for the Jinja2 Environment """
    return dict(
        extensions=('jinja2_base64_filters.Base64Filters',),
    )

