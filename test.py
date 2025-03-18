from mpitest import mpitest
from pathlib import Path

print(mpitest.__doc__)

worker = Path(mpitest.__file__).parent / 'worker'
print(worker)
mpitest.main(10,worker)