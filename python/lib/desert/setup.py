from setuptools import setup, find_packages

setup (
    name='desert',
    packages=find_packages(),
    zip_safe=True,
    entry_points =
    """
        [pygments.styles]
        desert = desert.desert:DesertStyle
    """,
)
