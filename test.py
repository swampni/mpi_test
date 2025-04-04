from mpitest import mpitest
from pathlib import Path


worker = Path(mpitest.__file__).parent / 'worker'
print(worker)
mpitest.main(1,worker)