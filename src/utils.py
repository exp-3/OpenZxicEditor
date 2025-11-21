import os
import subprocess
import platform as plat

elocal = os.getcwd()
platform = plat.machine()
ostype = plat.system()
binner = elocal + "/bin"
ebinner = binner + "/" + ostype + "/" + platform + "/"


def call(exe, extra_path=True, out=0, return_output=False):
    out_put_ = []
    if isinstance(exe, list):
        cmd = exe
        if extra_path:
            cmd[0] = f"{ebinner}{exe[0]}"
        cmd = [i for i in cmd if i]
    else:
        cmd = f'{ebinner}{exe}' if extra_path else exe
        if os.name == 'posix':
            cmd = cmd.split()
    conf = subprocess.CREATE_NO_WINDOW if os.name != 'posix' else 0
    try:
        ret = subprocess.Popen(cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                               stderr=subprocess.STDOUT, creationflags=conf)
        for i in iter(ret.stdout.readline, b""):
            try:
                out_put = i.decode("utf-8").strip()
            except (Exception, BaseException):
                out_put = i.decode("gbk","ignore").strip()
            out_put_.append(out_put)
            if out == 0:
                print(out_put)
    except subprocess.CalledProcessError as e:
        for i in iter(e.stdout.readline, b""):
            try:
                out_put = i.decode("utf-8").strip()
            except (Exception, BaseException):
                out_put = i.decode("gbk").strip()
            out_put_.append(out_put)
            if out == 0:
                print(out_put)
        return 2
    except (FileNotFoundError, OSError) as e:
        print(e)
        return 2 if not return_output else (2, e)
    ret.wait()
    return ret.returncode if not return_output else (ret.returncode, out_put_)

def fill(file_path, desired_size, fill_char=None):
    fill_char = fill_char or b'\xff'
    if not os.path.exists(file_path):
        open(file_path, 'w').close()
    bytes_to_fill = desired_size - os.path.getsize(file_path)
    if bytes_to_fill > 0:
        with open(file_path, 'a+b') as file:
            file.seek(0, 2)
            while bytes_to_fill > 0:
                chunk_size = min(bytes_to_fill, 16)
                file.write(fill_char * chunk_size)
                bytes_to_fill -= chunk_size