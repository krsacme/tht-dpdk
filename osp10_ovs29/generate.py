import argparse
import jinja2
import os
import six
import sys
import yaml

parser = argparse.ArgumentParser()
parser.add_argument('-r', '--roles-data',
                    dest='roles_data_file',
                    action='store',
                    help='Roles data file')
parser.add_argument('-i', '--input-jinja-template',
                    dest='j2_template',
                    action='store',
                    help='Jinija2 tempalte file to render')
args = parser.parse_args(sys.argv[1:])

if not args.roles_data_file:
    parser.print_help()
    sys.exit(1)
if not args.j2_template:
    parser.print_help()
    sys.exit(1)


def j2_render_and_write(j2_template, j2_data, out_f):
    yaml_f = out_f or j2_template.replace('.j2.yaml', '.yaml')
    try:
        # Render the j2 template
        with open(j2_template) as f:
            template = jinja2.Environment().from_string(f.read())
            r_template = template.render(**j2_data)
    except jinja2.exceptions.TemplateError as ex:
        error_msg = ("Error rendering template %s : %s"
                     % (yaml_f, six.text_type(ex)))
        print(error_msg)
        raise Exception(error_msg)
    with open(yaml_f, 'w') as f:
        f.write(r_template)


try:
    with open(args.roles_data_file) as f:
        role_data = yaml.safe_load(f.read())
except Exception as e:
   print("Exception: %s" % e)
   pass

role_names = [r.get('name') for r in role_data]
print("List of roles: %s" % ', '.join(role_names))
j2_data = {'roles': role_data}
j2_template = args.j2_template

if j2_template.endswith('.role.j2.yaml'):
    print("Jinja2 rendering role template %s" % j2_template)
    for role in role_data:
        j2_data = {'role': role}
        out_f = "-".join(
            [role.get('name').lower(),
             os.path.basename(j2_template).replace('.role.j2.yaml',
                                         '.yaml')])
        out_f_path = os.path.join(os.path.dirname(j2_template), out_f)
        j2_render_and_write(j2_template,
                            j2_data,
                            out_f_path)

elif j2_template.endswith('.j2.yaml'):
    print("jinja2 rendering %s" % j2_template)
    j2_data = {'roles': role_data}
    out_f = j2_template.replace('.j2.yaml', '.yaml')
    j2_render_and_write(j2_template, j2_data, out_f)

