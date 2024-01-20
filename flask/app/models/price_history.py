from dataclasses import dataclass
from datetime import datetime

from flask_sqlalchemy import PrimaryKeyConstraint

from ..extensions import database as db


@dataclass()
class PriceHistory(db.Model):
    __tablename__ = "price_history"

    price: float = db.Column(db.Float(), nullable=False)
    exchange: str = db.Column(db.String(255), nullable=False)
    trading_pair: str = db.Column(db.String(255), nullable=False)
    at_time: datetime = db.Column(db.DateTime(), nullable=False)
    volume: float = db.Column(db.Float(), nullable=False)

    __table_args__ = (PrimaryKeyConstraint("exchange", "trading_pair", "at_time"),)
