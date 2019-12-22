try:
    import cupy
    from torchsso.utils.cupy import to_cupy, from_cupy

    def cholesky(m, upper=True):
        m_cp = to_cupy(m)
        m_chl_cp = cupy.linalg.decomposition.cholesky(m_cp)
        if upper:
            m_chl_cp = m_chl_cp.transpose()
        return from_cupy(m_chl_cp)
except ImportError:
    import torch

    def cholesky(m, upper=True):
        return torch.cholesky(m, upper)
